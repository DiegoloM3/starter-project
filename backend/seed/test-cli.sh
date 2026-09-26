#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SCRIPT="$SCRIPT_DIR/seed-community.mjs"

expect_failure() {
  if node "$SCRIPT" "$@" >/dev/null 2>&1; then
    echo "Expected failure, but command succeeded: $*" >&2
    exit 1
  fi
}

# These must fail before Firebase Admin is loaded or any network operation starts.
expect_failure --apply
expect_failure --apply --project=wrong-project
expect_failure --apply --project wrong-project
expect_failure --apply --project
expect_failure --apply --project=case-study-symmetry --project=case-study-symmetry
expect_failure --apply --apply --project=case-study-symmetry
expect_failure --apply=1 --project=case-study-symmetry
expect_failure --unknown
expect_failure --help --project=case-study-symmetry

# A valid dry-run may omit --project or provide the exact project explicitly.
for project_args in "" "--project=case-study-symmetry"; do
  output=$(node "$SCRIPT" $project_args 2>/dev/null)
  node - "$output" <<'NODE'
const summary = JSON.parse(process.argv[2]);
if (summary.mode !== 'dry-run' || summary.project !== 'case-study-symmetry' || summary.count !== 2) {
  throw new Error('Unexpected dry-run summary');
}
NODE
done

echo "Community seed CLI checks passed."
