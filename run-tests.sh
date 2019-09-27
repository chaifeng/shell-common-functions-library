#!/usr/bin/env bash
set -uo pipefail

PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/sbin

bash_bin="$BASH"

OS="$(uname)"
case "$OS" in
    Darwin)
        if ! brew list --full-name --versions bash &>/dev/null; then
            brew install bash
        fi
        if [[ "$BASH" == /bin/bash ]]; then
            bash_bin="$(brew --prefix)"/bin/bash
        fi
        ;;
    Linux)
        if [[ -e /etc/os-release ]]; then
            source /etc/os-release
            OS="Linux-${ID}-${VERSION_ID}"
        fi
        ;;&
    Linux-alpine-*)
        apk update
        apk add coreutils diffutils perl-utils
        ;;
esac

"$bash_bin" --version

retval=0
for file in examples/test* lib/bach/examples/learn* lib/bach/tests/*.test.sh; do
    "$bash_bin" -euo pipefail "$file" || retval=1
done

exit "$retval"
