#!/usr/bin/env bash
set -uo pipefail

unset BACH_ASSERT_DIFF BACH_ASSERT_DIFF_OPTS
PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/sbin

bash_bin=/bin/bash

case "$(uname)" in
    Darwin)
        if ! brew list --full-name --versions bash &>/dev/null; then
            brew install bash
        fi
        bash_bin="$(brew --prefix)"/bin/bash
        ;;
esac

echo "$bash_bin"
"$bash_bin" --version

function out() {
    printf "\n\e[1;37;497;m%s\e[0;m\n" "$@"
} >&2

function err() {
    printf "\n\e[1;37;41;m%s\e[0;m\n\n" "$@"
} >&2

retval=0
cd "$(dirname "${BASH_SOURCE}")"
for file in examples/test* lib/bach/examples/learn* lib/bach/tests/*.test.sh; do
    out "Running $file"
    if grep -E "^[[:blank:]]*BACH_TESTS=.+" "$file"; then
        err "Found defination of BACH_TESTS in $file"
        retval=1
    fi
    "$bash_bin" -euo pipefail "$file" || retval=1
done

if [[ "$retval" -ne 0 ]]; then
    err "Test failed!"
fi

exit "$retval"
