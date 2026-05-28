#!/usr/bin/env bash
#
# Architecture Verification Script
# Enforces Clean Architecture layer boundaries in the Flutter project.
# Exit code 0 = clean, 1 = violations found.

set -euo pipefail

cd "$(dirname "$0")/.."

LIB="frontend/lib"
violations=0

rule_header() {
  echo ""
  echo "=== Rule $1: $2 ==="
}

check_violations() {
  local pattern="$1"
  local search_path="$2"
  local description="$3"

  local matches
  matches=$(grep -rn --include="*.dart" "$pattern" "$search_path" 2>/dev/null || true)

  if [ -n "$matches" ]; then
    echo "FAIL: $description"
    echo "$matches"
    violations=$((violations + 1))
  else
    echo "PASS: $description"
  fi
}

# --- Rule 1: Domain must not import from data/ or presentation/ ---
rule_header 1 "Domain layer isolation"

for domain_dir in "$LIB"/features/*/domain; do
  [ -d "$domain_dir" ] || continue
  feature=$(basename "$(dirname "$domain_dir")")

  check_violations \
    "import.*\/data\/" \
    "$domain_dir" \
    "[$feature] Domain must not import from data/"

  check_violations \
    "import.*\/presentation\/" \
    "$domain_dir" \
    "[$feature] Domain must not import from presentation/"
done

# --- Rule 2: Presentation must not import from data/ ---
rule_header 2 "Presentation layer isolation"

for pres_dir in "$LIB"/features/*/presentation; do
  [ -d "$pres_dir" ] || continue
  feature=$(basename "$(dirname "$pres_dir")")

  check_violations \
    "import.*\/data\/" \
    "$pres_dir" \
    "[$feature] Presentation must not import from data/"
done

# --- Rule 3: Domain must not import Flutter or Firebase packages ---
rule_header 3 "Domain package isolation"

for domain_dir in "$LIB"/features/*/domain; do
  [ -d "$domain_dir" ] || continue
  feature=$(basename "$(dirname "$domain_dir")")

  check_violations \
    "package:flutter" \
    "$domain_dir" \
    "[$feature] Domain must not import package:flutter"

  check_violations \
    "package:firebase" \
    "$domain_dir" \
    "[$feature] Domain must not import package:firebase"

  check_violations \
    "package:cloud_firestore" \
    "$domain_dir" \
    "[$feature] Domain must not import package:cloud_firestore"
done

# --- Rule 4: No print() in lib/ (debugPrint is OK) ---
rule_header 4 "No print() in lib/"

print_matches=$(grep -rn --include="*.dart" '\bprint(' "$LIB" 2>/dev/null | grep -v 'debugPrint' || true)

if [ -n "$print_matches" ]; then
  echo "FAIL: Found print() calls (use debugPrint or remove before commit)"
  echo "$print_matches"
  violations=$((violations + 1))
else
  echo "PASS: No print() calls found"
fi

# --- Summary ---
echo ""
echo "================================"
if [ "$violations" -gt 0 ]; then
  echo "FAILED: $violations violation(s) found"
  exit 1
else
  echo "PASSED: All architecture checks clean"
  exit 0
fi
