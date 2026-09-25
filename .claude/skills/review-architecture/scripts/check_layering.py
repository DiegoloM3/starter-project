#!/usr/bin/env python3
"""Mechanical layer-boundary checker for the review-architecture skill.

Checks the parts of docs/ARCHITECTURE_VIOLATIONS.md and docs/APP_ARCHITECTURE.md
that are pure import-direction / structural-naming facts -- the kind of thing a
grep can answer correctly every time. It deliberately does NOT check nesting
depth, argument count, single-responsibility, or naming quality: those need
judgment, and are handled by the skill's own reading pass instead (see SKILL.md).

Usage:
    python check_layering.py [target] [--repo-root PATH]

    target       Feature path relative to --repo-root.
                 Default: frontend/lib/features/user_articles
    --repo-root  Repo root to resolve `target` against. Default: cwd.

Exit code is 1 if any violation was found, 0 otherwise (0 also when the
target doesn't exist yet -- that's expected before a phase has produced it).
"""

import argparse
import re
import sys
from pathlib import Path

APP_PACKAGE = "news_app_clean_architecture"  # `name:` in frontend/pubspec.yaml

# Firebase/Firestore-family SDK packages: per ARCHITECTURE_VIOLATIONS.md Sec. 1.2.3/1.2.4,
# only data_sources/ may import these.
PROVIDER_PACKAGES = {"cloud_firestore", "firebase_storage", "firebase_core", "firebase_auth"}

# Zero-dependency, pure-Dart value/annotation packages. The existing
# daily_news/domain/entities/article.dart already imports `equatable` inside the
# domain layer, which is a literal deviation from ARCHITECTURE_VIOLATIONS.md Sec. 2.1.1
# ("except dart libraries"). We treat this as accepted precedent rather than silently
# forbidding or silently allowing everything -- see SKILL.md for how this gets reported.
PURE_DART_ALLOWED_PACKAGES = {"equatable", "meta"}

IMPORT_RE = re.compile(r"""^\s*import\s+['"]([^'"]+)['"]""")
THROW_RE = re.compile(r"(?<![\w$])throw\s")


def find_dart_files(root: Path):
    return sorted(root.rglob("*.dart"))


def layer_of(path: Path, feature_root: Path):
    rel = path.relative_to(feature_root).parts
    if not rel:
        return None
    if rel[0] in ("domain", "data", "presentation"):
        return rel[0]
    return None


def sublayer_of(path: Path, feature_root: Path):
    rel = path.relative_to(feature_root).parts
    if len(rel) < 2:
        return None
    return rel[1]


def extract_imports(text: str):
    out = []
    for i, line in enumerate(text.splitlines(), start=1):
        m = IMPORT_RE.match(line)
        if m:
            out.append((i, m.group(1)))
    return out


def classify_import(imp: str):
    """Returns (kind, detail). kind in {dart_sdk, internal_package, external_package, relative}."""
    if imp.startswith("dart:"):
        return "dart_sdk", None
    if imp.startswith("package:"):
        rest = imp[len("package:"):]
        pkg_name = rest.split("/", 1)[0]
        if pkg_name == APP_PACKAGE:
            internal_path = rest.split("/", 1)[1] if "/" in rest else ""
            return "internal_package", internal_path
        return "external_package", pkg_name
    return "relative", imp


def has_segment(path_str: str, segment: str) -> bool:
    """True if `segment` (e.g. 'data') appears as a full path segment, not a substring
    of some other folder/file name (e.g. avoids matching 'data' inside 'data_state.dart')."""
    return f"/{segment}/" in f"/{path_str}/"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("target", nargs="?", default="frontend/lib/features/user_articles")
    parser.add_argument("--repo-root", default=".")
    args = parser.parse_args()

    repo_root = Path(args.repo_root).resolve()
    feature_root = (repo_root / args.target).resolve()

    if not feature_root.exists():
        print(f"NOTE: target path does not exist yet: {feature_root}")
        print("Nothing to check -- expected if this phase hasn't produced this layer yet.")
        return 0

    files = find_dart_files(feature_root)
    if not files:
        print(f"NOTE: no .dart files found under {feature_root}")
        return 0

    findings = []  # dicts: severity(violation|note), file, line, rule, message
    passes = []

    for f in files:
        layer = layer_of(f, feature_root)
        sub = sublayer_of(f, feature_root)
        text = f.read_text(encoding="utf-8", errors="replace")
        rel_display = f.relative_to(repo_root).as_posix()
        imports = extract_imports(text)

        # ---------------- import-direction checks ----------------
        for line_no, imp in imports:
            kind, detail = classify_import(imp)

            if layer == "domain":
                if kind == "external_package" and detail not in PURE_DART_ALLOWED_PACKAGES:
                    findings.append(dict(
                        severity="violation", file=rel_display, line=line_no,
                        rule="ARCHITECTURE_VIOLATIONS.md Sec. 2.1.1",
                        message=(f"domain file imports third-party package 'package:{detail}/...'. "
                                 f"Business Layer must not import project modules or packages beyond "
                                 f"pure-Dart value types (dart: libs; {', '.join(sorted(PURE_DART_ALLOWED_PACKAGES))} "
                                 f"treated as accepted precedent -- see daily_news/domain/entities/article.dart).")
                    ))
                if kind == "internal_package" and detail and (has_segment(detail, "data") or has_segment(detail, "presentation")):
                    findings.append(dict(
                        severity="violation", file=rel_display, line=line_no,
                        rule="ARCHITECTURE_VIOLATIONS.md Sec. 2.1.1 / APP_ARCHITECTURE.md (Business Layer)",
                        message=f"domain file imports '{imp}', reaching into a data/ or presentation/ folder. Domain must be self-sustained pure Dart."
                    ))
                if kind == "relative" and (has_segment(imp, "data") or has_segment(imp, "presentation") or "../data" in imp or "../presentation" in imp):
                    findings.append(dict(
                        severity="violation", file=rel_display, line=line_no,
                        rule="ARCHITECTURE_VIOLATIONS.md Sec. 2.1.1 / APP_ARCHITECTURE.md (Business Layer)",
                        message=f"domain file has relative import '{imp}' reaching outside domain/."
                    ))

            if layer == "data":
                if sub != "data_sources" and kind == "external_package" and detail in PROVIDER_PACKAGES:
                    findings.append(dict(
                        severity="violation", file=rel_display, line=line_no,
                        rule="ARCHITECTURE_VIOLATIONS.md Sec. 1.2.3 / Sec. 1.2.4",
                        message=f"'{sub}' file imports provider SDK 'package:{detail}/...' directly -- only data_sources/ may import external providers."
                    ))
                if sub not in ("repository", "data_sources"):
                    # A data_source composing another data_source (e.g. a database
                    # wrapping its own DAO) is normal internal structure, not a
                    # bypass of the repository -- only flag imports from OUTSIDE
                    # both repository/ and data_sources/ itself.
                    hits_data_source = ("data_sources" in imp) if kind == "relative" else ("data_sources" in (detail or ""))
                    if hits_data_source:
                        findings.append(dict(
                            severity="violation", file=rel_display, line=line_no,
                            rule="ARCHITECTURE_VIOLATIONS.md Sec. 1.4.4",
                            message=f"'{sub}' file imports a data_source directly ('{imp}') -- only repository/ may import data_sources."
                        ))
                if kind == "internal_package" and detail and has_segment(detail, "presentation"):
                    findings.append(dict(
                        severity="violation", file=rel_display, line=line_no,
                        rule="ARCHITECTURE_VIOLATIONS.md Sec. 1.1.1",
                        message=f"data file imports from presentation/ ('{imp}') -- data layer must never import from any presentation layer."
                    ))
                if kind == "internal_package" and detail and "domain/usecases" in detail:
                    findings.append(dict(
                        severity="violation", file=rel_display, line=line_no,
                        rule="ARCHITECTURE_VIOLATIONS.md Sec. 1.1.2",
                        message=f"data file imports a use_case ('{imp}') -- data layer must not import use_cases."
                    ))

            if layer == "presentation":
                if kind == "external_package" and detail in PROVIDER_PACKAGES:
                    findings.append(dict(
                        severity="violation", file=rel_display, line=line_no,
                        rule="ARCHITECTURE_VIOLATIONS.md Sec. 3.1.1 / Sec. 3.2.3",
                        message=f"presentation file imports provider SDK 'package:{detail}/...' directly -- presentation must only talk to use_cases."
                    ))
                if kind == "internal_package" and detail and has_segment(detail, "data"):
                    findings.append(dict(
                        severity="violation", file=rel_display, line=line_no,
                        rule="ARCHITECTURE_VIOLATIONS.md Sec. 3.1.1",
                        message=f"presentation file imports from data/ ('{imp}') -- presentation must not directly access the data layer."
                    ))

        # ---------------- throw-location check (Sec. 1.2.1) ----------------
        if layer in ("domain", "presentation"):
            for i, line in enumerate(text.splitlines(), start=1):
                if THROW_RE.search(line):
                    findings.append(dict(
                        severity="violation", file=rel_display, line=i,
                        rule="ARCHITECTURE_VIOLATIONS.md Sec. 1.2.1",
                        message="'throw' found outside data_sources/ -- exceptions should only be thrown from data_sources."
                    ))

        # ---------------- models: extends / toEntity / fromRawData (Sec. 1.3.x) ----------------
        if layer == "data" and sub == "models":
            has_extends_entity = re.search(r"class\s+\w+\s+extends\s+\w*Entity\b", text)
            has_to_entity = re.search(r"\btoEntity\s*\(", text)
            has_from_raw_data = re.search(r"factory\s+\w+\.fromRawData\s*\(", text)
            has_from_json = re.search(r"factory\s+\w+\.fromJson\s*\(", text)

            if has_extends_entity:
                passes.append(f"{rel_display}: extends an Entity (Sec. 1.3.1)")
            else:
                findings.append(dict(severity="violation", file=rel_display, line=1,
                    rule="ARCHITECTURE_VIOLATIONS.md Sec. 1.3.1",
                    message="model class does not appear to 'extends' an Entity from domain/entities."))

            if has_to_entity:
                passes.append(f"{rel_display}: has toEntity() (Sec. 1.3.2)")
            else:
                findings.append(dict(severity="violation", file=rel_display, line=1,
                    rule="ARCHITECTURE_VIOLATIONS.md Sec. 1.3.2",
                    message="model class is missing a toEntity() conversion method."))

            if has_from_raw_data:
                passes.append(f"{rel_display}: has fromRawData() factory (Sec. 1.3.3)")
            else:
                extra = (" Found 'fromJson' instead -- that matches the OLD daily_news precedent, but the "
                         "WRITTEN rule is 'fromRawData'. For new code the written rule governs (see SKILL.md).") if has_from_json else ""
                findings.append(dict(severity="violation" if not has_from_json else "note",
                    file=rel_display, line=1,
                    rule="ARCHITECTURE_VIOLATIONS.md Sec. 1.3.3",
                    message=f"model class is missing a 'fromRawData' factory.{extra}"))

        # ---------------- repository impl naming (Sec. 1.4.1) ----------------
        if layer == "data" and sub == "repository":
            class_match = re.search(r"class\s+(\w+)\s+implements\s+(\w+)", text)
            if class_match:
                impl_name, iface_name = class_match.groups()
                expected = f"{iface_name}Impl"
                if impl_name == expected:
                    passes.append(f"{rel_display}: repository impl named '{expected}' (Sec. 1.4.1)")
                else:
                    findings.append(dict(severity="violation", file=rel_display, line=1,
                        rule="ARCHITECTURE_VIOLATIONS.md Sec. 1.4.1",
                        message=f"class '{impl_name}' implements '{iface_name}' but should be named '{expected}'."))

        # ---------------- domain/repository: entities not models (Sec. 2.4.2) ----------------
        if layer == "domain" and sub == "repository":
            if re.search(r"\bModel\b", text):
                findings.append(dict(severity="violation", file=rel_display, line=1,
                    rule="ARCHITECTURE_VIOLATIONS.md Sec. 2.4.2",
                    message="domain repository interface references a *Model type -- must return domain/entities only."))
            else:
                passes.append(f"{rel_display}: no *Model types in signatures (Sec. 2.4.2)")

        # ---------------- use_cases: exactly one call() (Sec. 2.3.1) ----------------
        if layer == "domain" and sub == "usecases":
            call_defs = re.findall(r"\bcall\s*\(", text)
            if len(call_defs) == 0:
                findings.append(dict(severity="violation", file=rel_display, line=1,
                    rule="APP_ARCHITECTURE.md (Use Cases) / ARCHITECTURE_VIOLATIONS.md Sec. 2.3.1",
                    message="no call() method found -- a use case must implement UseCase<Type,Params> with a call() method."))
            elif len(call_defs) == 1:
                passes.append(f"{rel_display}: exactly one call() method (Sec. 2.3.1)")
            else:
                findings.append(dict(severity="note", file=rel_display, line=1,
                    rule="ARCHITECTURE_VIOLATIONS.md Sec. 2.3.1",
                    message=f"found {len(call_defs)} occurrences of 'call(' -- confirm this use case still represents a SINGLE business operation."))

    # ---------------- output ----------------
    violations = [x for x in findings if x["severity"] == "violation"]
    notes = [x for x in findings if x["severity"] == "note"]

    print(f"# Mechanical layering check -- {feature_root.relative_to(repo_root).as_posix()}")
    print(f"# Files scanned: {len(files)}\n")

    if violations:
        print(f"## Violations ({len(violations)})\n")
        for v in violations:
            print(f"- [{v['rule']}] {v['file']}:{v['line']} -- {v['message']}")
    else:
        print("## Violations: none found by mechanical checks.")

    if notes:
        print(f"\n## Notes / judgment calls ({len(notes)})\n")
        for n in notes:
            print(f"- [{n['rule']}] {n['file']}:{n['line']} -- {n['message']}")

    if passes:
        print(f"\n## Mechanical checks passed ({len(passes)})\n")
        for p in passes:
            print(f"- {p}")

    print("\n# NOT covered by this script -- needs a reading pass (see SKILL.md):")
    print("# - nesting depth (CG3.2), argument count (CG3.5), SRP (CG3.3/CG5.2), class size (CG5.1/CG5.3)")
    print("# - naming QUALITY (CG2.1-2.5) beyond the structural patterns checked above")
    print("# - whether Cubits use use_cases correctly in practice (this only proves absence of forbidden imports)")

    return 1 if violations else 0


if __name__ == "__main__":
    sys.exit(main())
