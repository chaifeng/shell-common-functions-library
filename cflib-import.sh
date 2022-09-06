#!/usr/bin/env bash
# NO~~~~~~~~~~~~~~~~~~~~~~~~~~
#                    __   _,--="=--,_   __
#                   /  \."    .-.    "./  \
#                  /  ,/  _   : :   _  \/` \
#                  \  `| /o\  :_:  /o\ |\__/
#                   `-'| :="~` _ `~"=: |
#                      \`     (_)     `/
#               .-"-.   \      |      /   .-"-.
# .------------{     }--|  /,.-'-.,\  |--{     }------------.
#  )           (_)_)_)  \_/`~-===-~`\_/  (_(_(_)           (
# (                         Sorry!                          )
#  ) This file is supposed to be included in other script. (
# (                                                         )
#  )       export CFLIB_INC_PATH=/some/path                (
# (        source "$CFLIB_INC_PATH/cflib-import.sh"         )
#  )                                                       (
# '---------------------------------------------------------'
################################################################################

if [[ -z "${CFLIB_INC_PATH:-}" ]]; then
    if [[ "$0" = */cflib-import.sh ]] || [[ "$0" = cflib-import.sh ]]; then
        if [[ -n "${BASH_VERSION:-}" ]]; then
            this_pwd="$(realpath "$0")"
            this_pwd="${this_pwd%/*}"
            echo "CFLIB_INC_PATH='${this_pwd}'; source \"\$CFLIB_INC_PATH/cflib-import.sh\""
            unset this_pwd
        elif [[ -n "${ZSH_VERSION:-}" ]]; then
            echo "CFLIB_INC_PATH='${0:A:h}'; source \"\$CFLIB_INC_PATH/cflib-import.sh\""
        fi
        exit 0
    fi
    echo "# FATAL: The env 'CFLIB_INC_PATH' is empty!" >&2
    echo "#        Should be the path which includes file 'common.sh'" >&2
    return 1 &>/dev/null || exit 1
fi
exec 8>&2
export BASH_XTRACEFD=8

[[ -n "${__CFLIB_INC_COMMON_SH__:-}" ]] && type gnu_generic_getopts &>/dev/null && return

function __load_cflib__ {
    if [[ -n "${BASH_VERSION:-}" ]]; then
        for func in "$CFLIB_INC_PATH"/functions/*; do
            [[ -f "$func" ]] || continue
            # shellcheck source=/dev/null
            source "${func}"
        done
    elif [[ -n "${ZSH_VERSION:-}" ]]; then
        fpath+=("$CFLIB_INC_PATH/functions")
        for func in "$CFLIB_INC_PATH"/functions/*; do
            [[ -f "$func" ]] || continue
            autoload -Uz "${func##*/}"
        done
    else
        echo "Only support bash and zsh"
        return 2 &>/dev/null || exit 2
    fi
    unset func
} >&2 2>/dev/null 8>/dev/null

__load_cflib__

__CFLIB_INC_COMMON_SH__="$CFLIB_INC_PATH/common.sh"
