# shellcheck shell=bash
_TESTS_FAILED=0
assert_eq()       { [ "$1" = "$2" ] || { echo "FAIL: $3 (expected '$1', got '$2')"; _TESTS_FAILED=1; }; }
assert_contains() { case "$1" in *"$2"*) ;; *) echo "FAIL: $3 (missing '$2')"; _TESTS_FAILED=1;; esac; }
assert_file_exists() { [ -f "$1" ] || { echo "FAIL: $2 (no file $1)"; _TESTS_FAILED=1; }; }
assert_fail()     { if "$@" >/dev/null 2>&1; then echo "FAIL: expected nonzero exit: $*"; _TESTS_FAILED=1; fi; }
run_tests() {
  for fn in $(declare -F | awk '{print $3}' | grep '^test_'); do "$fn"; done
  if [ "$_TESTS_FAILED" -eq 0 ]; then echo "ALL PASS"; else echo "TESTS FAILED"; exit 1; fi
}
