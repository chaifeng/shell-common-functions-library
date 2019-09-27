#!/usr/bin/env bash
set -uo pipefail

PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/sbin

bash_bin="$BASH"

case "$(uname)" in
    Darwin)
        if ! brew list --full-name --versions bash &>/dev/null; then
            brew install bash
        fi
        bash_bin="$(brew --prefix)"/bin/bash
        ;;
    Linux)
        if [[ -e /etc/os-release ]]; then
            source /etc/os-release
            case "$ID" in
                alpine)
                    apk update
                    apk add git coreutils diffutils perl-utils
                    ;;
            esac
        fi
        ;;
esac

"$bash_bin" --version

retval=0
for file in examples/test* lib/bach/examples/learn* lib/bach/tests/*.test.sh; do
    "$bash_bin" -euo pipefail "$file" || retval=1
done

exit "$retval"
