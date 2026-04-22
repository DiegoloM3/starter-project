#!/usr/bin/env python3
"""
generate_structure.py
Generates Symmetry's Clean Architecture folder structure for a Flutter project.

Usage:
    python generate_structure.py
    python generate_structure.py --project my_app --features articles auth profile
    python generate_structure.py --dry-run

Rules enforced (from Symmetry's architecture doc):
  - Data Layer   → can only import from Domain Layer
  - Domain Layer → pure Dart, no external imports
  - Presentation → can only import from Domain Layer (use cases)
  - All layers can import from core/ and shared/ (respecting hierarchy)
"""

import argparse
import os
import sys
from pathlib import Path
from textwrap import dedent


# ──────────────────────────────────────────────
# ANSI colours
# ──────────────────────────────────────────────
GREEN  = "\033[92m"
BLUE   = "\033[94m"
YELLOW = "\033[93m"
RESET  = "\033[0m"


# ──────────────────────────────────────────────
# Architecture reference markdown
# ──────────────────────────────────────────────
ARCHITECTURE_MD = dedent("""\
# Symmetry App Architecture

Symmetry follows an adaptation of **Clean Architecture** split into three layers
with strict dependency rules.

---

## Dependency Rules (MUST NOT be violated)

| From \\ To       | core | shared | Domain | Data | Presentation |
|-----------------|------|--------|--------|------|--------------|
| **Data**        | ✅   | ✅     | ✅     | —    | ❌           |
| **Domain**      | ❌   | ❌     | —      | ❌   | ❌           |
| **Presentation**| ✅   | ✅     | ✅     | ❌   | —            |

> **Domain is pure Dart.** No Flutter packages, no project imports outside its own folder.

---

## Folder Structure

```
lib/
├── config/
│   ├── routes/          # go_router or Navigator 2 route definitions
│   └── theme/           # ThemeData, colours, typography
│
├── core/
│   ├── constants/       # App-wide constants (API URLs, timeouts, keys)
│   ├── resources/       # Generic wrappers: DataState<T>, Either<L,R>, Failure
│   └── usecase/         # Abstract UseCase<Type, Params> base class
│
├── shared/
│   └── {widget|util}/   # Reusable widgets and utilities (no feature logic)
│
└── features/
    └── {feature}/
        ├── data/
        │   ├── data_sources/   # ONLY classes that touch external services
        │   ├── models/         # Extend domain Entities; handle JSON parsing
        │   └── repository/     # Implement domain Repository interfaces
        │
        ├── domain/
        │   ├── entities/       # Business objects (pure Dart dataclasses)
        │   ├── use_cases/      # One file per use case, implements UseCase<T,P>
        │   └── repository/     # Abstract repository contracts
        │
        └── presentation/
            ├── bloc/           # BLoC and Cubits (import use cases only)
            ├── screens/        # Full-page widgets
            └── widgets/        # Feature-specific reusable widgets
```

---

## Layer Responsibilities

### Data Layer
- **data_sources/** — sole point of contact with Firebase, REST APIs,
  SharedPreferences, etc. Never called directly from presentation.
- **models/** — extend entities and add `fromJson` / `toJson` / `fromFirestore`.
- **repository/** — concrete implementations of domain repository interfaces.

### Domain Layer *(pure Dart)*
- **entities/** — define the shape of business objects. No parsing, no UI.
- **use_cases/** — one task per class. Call repository interfaces, never
  concrete implementations.
- **repository/** — abstract classes (contracts) fulfilled by the data layer.

### Presentation Layer
- **bloc/** — BLoC / Cubits only import use cases. No direct repo access.
- **screens/** — compose widgets, listen to BLoC states.
- **widgets/** — stateless or simple stateful widgets; no business logic.

---

## Violations Reference

See `docs/ARCHITECTURE_VIOLATIONS.md` for the full list of forbidden patterns.

Quick reference — these are **always wrong**:
- Importing a `data/` class from `presentation/`
- Importing a Flutter package inside `domain/`
- Calling a data source directly from a BLoC
- Putting business logic inside a widget

---

## Testing Conventions

The `test/` folder mirrors `lib/` 1-to-1:

```
test/
└── features/
    └── {feature}/
        ├── data/
        │   └── repository/          # repository_impl_test.dart
        ├── domain/
        │   └── use_cases/           # use_case_test.dart
        └── presentation/
            └── bloc/                # cubit_test.dart
```

Every file in `lib/` that contains logic should have a matching `_test.dart`.

---

## Core Abstractions

### `UseCase<Type, Params>`
```dart
// core/usecase/usecase.dart
abstract class UseCase<Type, Params> {
  Future<DataState<Type>> call(Params params);
}

class NoParams {}
```

### `DataState<T>`
```dart
// core/resources/data_state.dart
abstract class DataState<T> {
  final T? data;
  final String? error;
  const DataState({this.data, this.error});
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data: data);
}

class DataFailed<T> extends DataState<T> {
  const DataFailed(String error) : super(error: error);
}
```

---

*Generated by `generate_structure.py` — Symmetry Engineering*
""")


# ──────────────────────────────────────────────
# Stub file content generators
# ──────────────────────────────────────────────

def _dart_header(description: str) -> str:
    return f"// {description}\n// TODO: implement\n"


def core_files() -> dict[str, str]:
    return {
        "core/usecase/usecase.dart": dedent("""\
            /// Base class for all use cases.
            /// [Type]   — the return type wrapped in DataState.
            /// [Params] — the input parameters (use NoParams when none needed).
            abstract class UseCase<Type, Params> {
              Future<DataState<Type>> call(Params params);
            }

            class NoParams {
              const NoParams();
            }
            """),

        "core/resources/data_state.dart": dedent("""\
            /// Generic wrapper for data layer responses.
            abstract class DataState<T> {
              final T? data;
              final String? error;
              const DataState({this.data, this.error});
            }

            class DataSuccess<T> extends DataState<T> {
              const DataSuccess(T data) : super(data: data);
            }

            class DataFailed<T> extends DataState<T> {
              const DataFailed(String error) : super(error: error);
            }
            """),

        "core/constants/app_constants.dart": dedent("""\
            /// App-wide constants. Keep environment-specific values in .env.
            class AppConstants {
              AppConstants._();

              static const String appName = 'Symmetry';
              static const int defaultPageSize = 20;
            }
            """),

        "config/routes/app_router.dart":
            _dart_header("Route definitions (go_router or Navigator 2)"),

        "config/theme/app_theme.dart":
            _dart_header("ThemeData, colour palette, typography"),
    }


def _plural(name: str) -> str:
    """Simple pluralizer — avoids double-s for names already ending in 's'."""
    if name.endswith("s"):
        return name
    if name.endswith("y") and not name[-2] in "aeiou":
        return name[:-1] + "ies"
    return name + "s"


def feature_files(feature: str) -> dict[str, str]:
    """Returns a dict of relative-path → file-content for one feature."""
    f = feature
    F = feature.capitalize()
    Fp = _plural(F)   # e.g. "Article" → "Articles", "Articles" → "Articles"

    return {
        # ── Domain ──────────────────────────────────────────────────────
        f"features/{f}/domain/entities/{f}_entity.dart": dedent(f"""\
            /// {F} business entity.
            /// Pure Dart — no Flutter imports, no JSON parsing.
            class {F}Entity {{
              final String id;
              // TODO: add fields

              const {F}Entity({{required this.id}});
            }}
            """),

        f"features/{f}/domain/repository/{f}_repository.dart": dedent(f"""\
            import '../entities/{f}_entity.dart';
            import '../../../../core/resources/data_state.dart';

            /// Contract fulfilled by the Data Layer.
            /// Domain layer only knows this interface.
            abstract class {F}Repository {{
              Future<DataState<List<{F}Entity>>> getAll();
              Future<DataState<{F}Entity>> getById(String id);
              Future<DataState<{F}Entity>> create({F}Entity entity);
            }}
            """),

        f"features/{f}/domain/use_cases/get_{_plural(f)}_use_case.dart": dedent(f"""\
            import '../../../../core/resources/data_state.dart';
            import '../../../../core/usecase/usecase.dart';
            import '../entities/{f}_entity.dart';
            import '../repository/{f}_repository.dart';

            /// Retrieves the full list of {_plural(f)}.
            class Get{Fp}UseCase implements UseCase<List<{F}Entity>, NoParams> {{
              final {F}Repository _repository;

              const Get{Fp}UseCase(this._repository);

              @override
              Future<DataState<List<{F}Entity>>> call(NoParams params) {{
                return _repository.getAll();
              }}
            }}
            """),

        f"features/{f}/domain/use_cases/get_{f}_by_id_use_case.dart": dedent(f"""\
            import '../../../../core/resources/data_state.dart';
            import '../../../../core/usecase/usecase.dart';
            import '../entities/{f}_entity.dart';
            import '../repository/{f}_repository.dart';

            class Get{F}ByIdParams {{
              final String id;
              const Get{F}ByIdParams(this.id);
            }}

            class Get{F}ByIdUseCase implements UseCase<{F}Entity, Get{F}ByIdParams> {{
              final {F}Repository _repository;

              const Get{F}ByIdUseCase(this._repository);

              @override
              Future<DataState<{F}Entity>> call(Get{F}ByIdParams params) {{
                return _repository.getById(params.id);
              }}
            }}
            """),

        f"features/{f}/domain/use_cases/create_{f}_use_case.dart": dedent(f"""\
            import '../../../../core/resources/data_state.dart';
            import '../../../../core/usecase/usecase.dart';
            import '../entities/{f}_entity.dart';
            import '../repository/{f}_repository.dart';

            class Create{F}UseCase implements UseCase<{F}Entity, {F}Entity> {{
              final {F}Repository _repository;

              const Create{F}UseCase(this._repository);

              @override
              Future<DataState<{F}Entity>> call({F}Entity params) {{
                return _repository.create(params);
              }}
            }}
            """),

        # ── Data ────────────────────────────────────────────────────────
        f"features/{f}/data/models/{f}_model.dart": dedent(f"""\
            import '../../domain/entities/{f}_entity.dart';

            /// Extends [{F}Entity] to handle JSON / Firestore parsing.
            /// Never used directly outside the data layer.
            class {F}Model extends {F}Entity {{
              const {F}Model({{required super.id}});

              factory {F}Model.fromJson(Map<String, dynamic> json) {{
                return {F}Model(id: json['id'] as String);
              }}

              Map<String, dynamic> toJson() {{
                return {{'id': id}};
              }}
            }}
            """),

        f"features/{f}/data/data_sources/{f}_remote_data_source.dart": dedent(f"""\
            import '../models/{f}_model.dart';

            /// ONLY class allowed to talk to the remote API / Firestore.
            abstract class {F}RemoteDataSource {{
              Future<List<{F}Model>> getAll();
              Future<{F}Model> getById(String id);
              Future<{F}Model> create({F}Model model);
            }}

            class {F}RemoteDataSourceImpl implements {F}RemoteDataSource {{
              // TODO: inject HTTP client or Firestore instance

              @override
              Future<List<{F}Model>> getAll() async {{
                // TODO: implement
                throw UnimplementedError();
              }}

              @override
              Future<{F}Model> getById(String id) async {{
                throw UnimplementedError();
              }}

              @override
              Future<{F}Model> create({F}Model model) async {{
                throw UnimplementedError();
              }}
            }}
            """),

        f"features/{f}/data/repository/{f}_repository_impl.dart": dedent(f"""\
            import '../../../../core/resources/data_state.dart';
            import '../../domain/entities/{f}_entity.dart';
            import '../../domain/repository/{f}_repository.dart';
            import '../data_sources/{f}_remote_data_source.dart';
            import '../models/{f}_model.dart';

            /// Concrete implementation of [{F}Repository].
            /// The presentation layer never imports this class.
            class {F}RepositoryImpl implements {F}Repository {{
              final {F}RemoteDataSource _remoteDataSource;

              const {F}RepositoryImpl(this._remoteDataSource);

              @override
              Future<DataState<List<{F}Entity>>> getAll() async {{
                try {{
                  final models = await _remoteDataSource.getAll();
                  return DataSuccess(models);
                }} catch (e) {{
                  return DataFailed(e.toString());
                }}
              }}

              @override
              Future<DataState<{F}Entity>> getById(String id) async {{
                try {{
                  final model = await _remoteDataSource.getById(id);
                  return DataSuccess(model);
                }} catch (e) {{
                  return DataFailed(e.toString());
                }}
              }}

              @override
              Future<DataState<{F}Entity>> create({F}Entity entity) async {{
                try {{
                  final model = {F}Model(id: entity.id);
                  final result = await _remoteDataSource.create(model);
                  return DataSuccess(result);
                }} catch (e) {{
                  return DataFailed(e.toString());
                }}
              }}
            }}
            """),

        # ── Presentation ────────────────────────────────────────────────
        f"features/{f}/presentation/bloc/{f}_cubit.dart": dedent(f"""\
            import 'package:flutter_bloc/flutter_bloc.dart';

            import '../../domain/entities/{f}_entity.dart';
            import '../../domain/use_cases/get_{_plural(f)}_use_case.dart';
            import '{f}_state.dart';
            import '../../../../core/usecase/usecase.dart';

            /// Presentation state manager for the {F} feature.
            /// ONLY imports use cases — never repositories or data sources.
            class {F}Cubit extends Cubit<{F}State> {{
              final Get{Fp}UseCase _get{Fp};

              {F}Cubit({{required Get{Fp}UseCase get{Fp}}})
                  : _get{Fp} = get{Fp},
                    super(const {F}Initial());

              Future<void> load{Fp}() async {{
                emit(const {F}Loading());
                final result = await _get{Fp}(const NoParams());
                result.data != null
                    ? emit({F}Loaded(result.data!))
                    : emit({F}Error(result.error ?? 'Unknown error'));
              }}
            }}
            """),

        f"features/{f}/presentation/bloc/{f}_state.dart": dedent(f"""\
            import 'package:equatable/equatable.dart';
            import '../../domain/entities/{f}_entity.dart';

            sealed class {F}State extends Equatable {{
              const {F}State();

              @override
              List<Object?> get props => [];
            }}

            class {F}Initial extends {F}State {{
              const {F}Initial();
            }}

            class {F}Loading extends {F}State {{
              const {F}Loading();
            }}

            class {F}Loaded extends {F}State {{
              final List<{F}Entity> items;
              const {F}Loaded(this.items);

              @override
              List<Object?> get props => [items];
            }}

            class {F}Error extends {F}State {{
              final String message;
              const {F}Error(this.message);

              @override
              List<Object?> get props => [message];
            }}
            """),

        f"features/{f}/presentation/screens/{f}_screen.dart": dedent(f"""\
            import 'package:flutter/material.dart';
            import 'package:flutter_bloc/flutter_bloc.dart';

            import '../bloc/{f}_cubit.dart';
            import '../bloc/{f}_state.dart';
            import '../widgets/{f}_list_widget.dart';

            class {F}Screen extends StatefulWidget {{
              const {F}Screen({{super.key}});

              @override
              State<{F}Screen> createState() => _{F}ScreenState();
            }}

            class _{F}ScreenState extends State<{F}Screen> {{
              @override
              void initState() {{
                super.initState();
                context.read<{F}Cubit>().load{Fp}();
              }}

              @override
              Widget build(BuildContext context) {{
                return Scaffold(
                  appBar: AppBar(title: const Text('{F}')),
                  body: BlocBuilder<{F}Cubit, {F}State>(
                    builder: (context, state) {{
                      return switch (state) {{
                        {F}Loading() => const Center(child: CircularProgressIndicator()),
                        {F}Loaded(items: final items) => {F}ListWidget(items: items),
                        {F}Error(message: final msg) => Center(child: Text(msg)),
                        _ => const SizedBox.shrink(),
                      }};
                    }},
                  ),
                );
              }}
            }}
            """),

        f"features/{f}/presentation/widgets/{f}_list_widget.dart": dedent(f"""\
            import 'package:flutter/material.dart';
            import '../../domain/entities/{f}_entity.dart';

            class {F}ListWidget extends StatelessWidget {{
              final List<{F}Entity> items;
              const {F}ListWidget({{super.key, required this.items}});

              @override
              Widget build(BuildContext context) {{
                if (items.isEmpty) {{
                  return const Center(child: Text('No items yet.'));
                }}
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) => ListTile(title: Text(items[i].id)),
                );
              }}
            }}
            """),

        # ── Tests ───────────────────────────────────────────────────────
        f"test/features/{f}/domain/use_cases/get_{_plural(f)}_use_case_test.dart": dedent(f"""\
            import 'package:flutter_test/flutter_test.dart';
            import 'package:mocktail/mocktail.dart';

            // TODO: import your use case and mock repository here

            class Mock{F}Repository extends Mock {{
              // implements {F}Repository
            }}

            void main() {{
              late Mock{F}Repository mockRepo;

              setUp(() {{
                mockRepo = Mock{F}Repository();
              }});

              group('Get{Fp}UseCase', () {{
                test('returns list of {_plural(f)} on success', () async {{
                  // arrange
                  // when(mockRepo.getAll()).thenAnswer((_) async => [...]);
                  // act
                  // assert
                }});
              }});
            }}
            """),

        f"test/features/{f}/data/repository/{f}_repository_impl_test.dart":
            _dart_header(f"Tests for {F}RepositoryImpl"),

        f"test/features/{f}/presentation/bloc/{f}_cubit_test.dart":
            _dart_header(f"Tests for {F}Cubit"),
    }


# ──────────────────────────────────────────────
# Filesystem helpers
# ──────────────────────────────────────────────

def write_file(path: Path, content: str, dry_run: bool) -> None:
    if dry_run:
        print(f"  {BLUE}[DRY]{RESET} {path}")
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    if not path.exists():
        path.write_text(content, encoding="utf-8")
        print(f"  {GREEN}[CREATE]{RESET} {path}")
    else:
        print(f"  {YELLOW}[SKIP]{RESET}   {path}  (already exists)")


def touch_gitkeep(directory: Path, dry_run: bool) -> None:
    """Place a .gitkeep in empty directories so git tracks them."""
    keep = directory / ".gitkeep"
    if dry_run:
        print(f"  {BLUE}[DRY]{RESET} {keep}")
        return
    directory.mkdir(parents=True, exist_ok=True)
    if not keep.exists():
        keep.touch()
        print(f"  {GREEN}[CREATE]{RESET} {keep}")


# ──────────────────────────────────────────────
# Main generation logic
# ──────────────────────────────────────────────

def generate(project_root: str, features: list[str], dry_run: bool) -> None:
    root = Path(project_root)
    lib  = root / "lib"
    test = root / "test"

    print(f"\n{BLUE}▶ Generating Symmetry Clean Architecture{RESET}")
    print(f"  Project root : {root.resolve()}")
    print(f"  Features     : {', '.join(features)}")
    print(f"  Mode         : {'DRY RUN' if dry_run else 'WRITE'}\n")

    # ── Architecture reference doc ──────────────────────────────────────
    docs_dir = root / "docs"
    write_file(docs_dir / "APP_ARCHITECTURE.md", ARCHITECTURE_MD, dry_run)

    # ── Core files ─────────────────────────────────────────────────────
    print(f"{BLUE}── core & config{RESET}")
    for rel_path, content in core_files().items():
        write_file(lib / rel_path, content, dry_run)

    # Shared — just .gitkeep so the folder exists
    touch_gitkeep(lib / "shared", dry_run)

    # ── Features ───────────────────────────────────────────────────────
    for feature in features:
        feature = feature.strip().lower().replace("-", "_").replace(" ", "_")
        print(f"\n{BLUE}── feature: {feature}{RESET}")
        files = feature_files(feature)
        for rel_path, content in files.items():
            # Files under test/ go to root/test/; everything else to root/lib/
            if rel_path.startswith("test/"):
                target = root / rel_path
            else:
                target = lib / rel_path
            write_file(target, content, dry_run)

    # ── Summary ────────────────────────────────────────────────────────
    action = "Would create" if dry_run else "Created"
    n_features = len(features)
    print(f"\n{GREEN}✔ Done.{RESET} {action} structure for {n_features} feature(s).")
    print(f"  Reference doc → {docs_dir / 'APP_ARCHITECTURE.md'}\n")

    if not dry_run:
        print("Next steps:")
        print("  1. Add dependencies to pubspec.yaml:")
        print("       flutter_bloc, equatable, mocktail, go_router, dio")
        print("  2. Register your repositories with a DI solution (get_it).")
        print("  3. Fill in the TODO stubs in each generated file.")
        print("  4. Run: flutter pub get\n")


# ──────────────────────────────────────────────
# CLI
# ──────────────────────────────────────────────

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate Symmetry Clean Architecture for a Flutter project.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=dedent("""\
            Examples:
              python generate_structure.py
              python generate_structure.py --features articles auth profile
              python generate_structure.py --project ~/dev/my_app --features articles
              python generate_structure.py --dry-run --features articles auth
            """),
    )
    parser.add_argument(
        "--project",
        default=".",
        metavar="PATH",
        help="Root directory of the Flutter project (default: current directory).",
    )
    parser.add_argument(
        "--features",
        nargs="+",
        default=["articles", "auth"],
        metavar="FEATURE",
        help="List of features to scaffold (default: articles auth).",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print what would be created without writing any files.",
    )
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    try:
        generate(
            project_root=args.project,
            features=args.features,
            dry_run=args.dry_run,
        )
    except KeyboardInterrupt:
        print("\nAborted.")
        sys.exit(1)
