#!/usr/bin/env bash
set -euo pipefail
export CFLIB_INC_PATH="${0%/*}/.."; source "$CFLIB_INC_PATH/cflib-import.sh"

declare -A OPTIONS
OPTIONS[help]=false
OPTIONS[debug]=false
OPTIONS[hello]=World
OPTIONS[title]="a demo of gnu_generic_getopts"

gnu_generic_getopts - "${@}" <<HELP || { echo "Found error" >&2; exit 1; }
Usage:
  a demo for the function gnu_generic_getopts

Options:
  -d, --debug          enable debug output
      --hello=WORLD    hello option
  -t, --title=TITLE    set title

  -h, --help     show this help message

Examples:
  $0 --help
  $0 -h
  $0 --hello Shell
  $0 --hello=Shell
  $0 -d
HELP


if [[ "${OPTIONS[help]}" == true ]]; then
  echo "$HELP_MESSAGE"
  exit 0
fi

is_debug_enabled="${OPTIONS[debug]}"
world="${OPTIONS[hello]}"
title="${OPTIONS[title]}"

if [[ "$is_debug_enabled" == true ]]; then
  exec 8>&2
  BASH_XTRACEFD=8
  set -x
fi

printf "%.1s" "="{1..78}
echo -e "\n$title"
printf "%.1s" "="{1..78}
echo
echo "Hello $world"


# Testing ...

set -euo pipefail

exec 3>&2

function error() {
  echo -ne '\e[1;37;41m[ERROR] '
  echo -ne "$*"
  echo -e '\e[0m'
} >&3

function success() {
  echo -ne '\e[1;32m[PASS] '
  echo -ne "$*"
  echo -e '\e[0m'
} >&3

function debug() {
  echo -ne '\e[1;34m[DEBUG] '
  echo -ne "$*"
  echo -e '\e[0m'
} >&3

function assert_gnu_generic_getopts() (
  local -i retval=0

  local -i loopstart=0 loopend="${#expectedOptionsError[@]}"
  [[ "${#OPTIONS_ERROR[@]}" -eq $loopend ]] || { retval=1; debug "OPTIONS_ERROR length not equals"; }
  [[ -n "${ZSH_VERSION:-}" ]] && : $(( loopstart++ )) $(( loopend++ ))
  for (( i=loopstart; i<loopend; i++ )); do
      [[ "testing:${OPTIONS_ERROR[$i]:-actual}" == "testing:${expectedOptionsError[$i]:-expected}" ]] ||
          { retval=1; debug "OPTIONS_ERROR[$i]: expected=${expectedOptionsError[$i]:-${i}expected}, actual=${OPTIONS_ERROR[$i]:-<NULL>}"; }
  done
  [[ "${#OPTIONS_ERROR[@]}" -gt 0 ]] && return "$retval"

  [[ "${#OPTIONS[@]}" -eq "${#expectedOptions[@]}" ]] || { retval=1; debug "OPTIONS length not equals"; }
  declare -a optlist
  if [[ -n "${BASH_VERSION:-}" ]]; then
    optlist+=("${!expectedOptions[@]}")
  else
    optlist+=("${(@k)expectedOptions}")
  fi
  for opt in "${optlist[@]}"; do
    [[ $opt == "s" ]] && continue
    [[ "testing:${OPTIONS[$opt]:-actual}" == "testing:${expectedOptions[$opt]:-expected}" ]] ||
      { retval=1; debug "OPTIONS[$opt]: expected=${expectedOptions[$opt]:-$opt expected}, actual=${OPTIONS[$opt]:-<NULL>}"; }
  done

  local -i loopstart=0 loopend="${#expectedArguments[@]}"
  [[ "${#ARGUMENTS[@]}" -eq $loopend ]] || { retval=1; debug "ARGUMENTS length not equals"; }
  [[ -n "${ZSH_VERSION:-}" ]] && : $(( loopstart++ )) $(( loopend++ ))
  for (( i=loopstart; i<loopend; i++ )); do
    [[ "testing:${ARGUMENTS[$i]:-actual}" == "testing:${expectedArguments[$i]:-expected}" ]] ||
      { retval=1; debug "ARGUMENTS[$i]: expected=${expectedArguments[$i]:-${i}expected}, actual=${ARGUMENTS[$i]:-<NULL>}"; }
  done
  return $retval
)

declare -i testsCount=0 testsFailed=0

function runTest() {
  local name="${*}"
  local help_msg
  help_msg="$(cat)"
  unset OPTIONS ARGUMENTS
  gnu_generic_getopts - "$@" <<< "$help_msg" || true
  if assert_gnu_generic_getopts "$@"; then
    success "$name"
    : $(( testsCount++ ))
  else
    error "FAILED: $name"
    : $(( testsFailed++ ))
  fi
  expectedOptions=( )
  expectedArguments=( )
  expectedOptionsError=( )
  OPTIONS=( )
} &>/dev/null

declare -A OPTIONS=( )
declare -A expectedOptions=( )
declare -a expectedArguments=( )
declare -a expectedOptionsError=( )

#############################################################################
#                                TEST CASES
#############################################################################

runTest <<EOF
EOF

expectedOptions[help]=true
expectedArguments=( --foo foobar --bar )
runTest --help --foo foobar --bar <<EOF
EOF

expectedOptions[version]=true
runTest --version <<EOF
  -v, --version    show version
EOF

expectedOptions[version]=true
runTest -v <<EOF
  -v, --version    show version
EOF

expectedOptions[v]=true
runTest -v <<EOF
  -v      show version
EOF

OPTIONS[verbose]=true
expectedOptions[verbose]=false
runTest --verbose=no <<EOF
  -V, --verbose      verbose option
EOF

expectedOptions[version]=true
runTest --version=yes <<EOF
  -v, --version      show version
EOF

expectedOptions[version]=true
runTest --version <<EOF
  --version      show version
EOF

expectedOptions[t]=true
runTest -t <<EOF
  -t
EOF

expectedOptions[tab]=true
runTest --tab <<EOF
  --tab
EOF

expectedOptions[tab]=true
runTest -t <<EOF
  -t, --tab
EOF

expectedOptions[n]=tom
runTest -n tom <<EOF
  -n NAME
EOF

expectedOptions[name]="Tom Hanks"
runTest --name "Tom Hanks" <<EOF
  --name=NAME
EOF

expectedOptions[name]="Tom Hanks"
runTest -nTom\ Hanks <<EOF
  -n, --name=NAME
EOF

expectedOptions[t]=true
runTest -t <<EOF
  -t	short option, allow using tab to split
EOF

expectedOptions[tab]=true
runTest --tab <<EOF
  --tab	long option, allow using tab to split
EOF

expectedOptions[tab]=true
runTest -t <<EOF
  -t, --tab	allow using tab to split
EOF

expectedOptions[n]=tom
runTest -n tom <<EOF
  -n NAME	short option, allow using tab to split
EOF

expectedOptions[name]="Tom Hanks"
runTest --name "Tom Hanks" <<EOF
  --name=NAME	long option, allow using tab to split
EOF

expectedOptions[name]="Tom Hanks"
runTest -nTom\ Hanks <<EOF
  -n, --name=NAME	allow using tab to split
EOF

expectedOptions[domain]=example.com
runTest --domain example.com <<EOF
  -d, --domain=DOMAIN-NAME    domain name
EOF

expectedOptions[domain]=example.com
runTest -D example.com <<EOF
  -D, --domain=DOMAIN-NAME    domain name
EOF

expectedOptions[domain]=example.com
runTest --domain=example.com <<EOF
  -d, --domain=DOMAIN-NAME    domain name
EOF

expectedOptions[d]=example.com
runTest -d example.com <<EOF
  -d DOMAIN-NAME    domain name
EOF

expectedOptions[d]=example.com
runTest -dexample.com <<EOF
  -d DOMAIN-NAME    domain name
EOF

expectedOptions[domain]=example.com
runTest --domain=example.com <<EOF
  --domain=DOMAIN-NAME    domain name
EOF

expectedOptions[domain]=example.com
runTest -dexample.com <<EOF
  -d, --domain DOMAIN-NAME    domain name, using a single space
EOF

expectedOptions[domain]=example.com
runTest --domain=example.com <<EOF
  --domain DOMAIN-NAME    domain name, using a single space
EOF

expectedOptions[tags]=foo
runTest --tags=foo <<EOF
  --tags=TAG,[TAG,...]   multiple tags
EOF

expectedOptions[tags]=foo,bar
runTest --tags=foo,bar <<EOF
  --tags=TAG,[TAG,...]   multiple tags
EOF

expectedOptions[tags]=foo,bar
runTest --tags=foo --tags bar <<EOF
  --tags=TAG,[TAG,...]   multiple tags
EOF

expectedOptions[tags]=foo,bar
runTest -t foo --tags bar <<EOF
  -t, --tags=TAG,[TAG,...]   multiple tags
EOF

expectedOptions[user]=bar:secret
runTest -u foo --user bar:secret <<EOF
  -u, --user=USER[:PASSWORD]    Server user and password
EOF

expectedOptions[user]=bar
runTest -ubar <<EOF
  -u, --user=USER[:PASSWORD]    Server user and password
EOF

expectedOptions[a]=true
expectedOptions[b]=true
runTest -a -b <<EOF
  -a   option a
  -b   option b
EOF

expectedOptions[a]=true
expectedOptions[b]=true
runTest -ab <<EOF
  -a   option a
  -b   option b
EOF

expectedOptions[a]=true
expectedOptions[b]=true
expectedArguments=( -c -d )
runTest -ab -- -c -d <<EOF
  -a   option a
  -b   option b
  -c   option c
  -d   option d
EOF

expectedOptions[a]=true
expectedOptions[b]=true
expectedArguments=( -ab -cd )
runTest -ab -- -ab -cd <<EOF
  -a   option a
  -b   option b
  -c   option c
  -d   option d
EOF

expectedOptions[name]="foo bar"
runTest -n"foo bar" <<EOF
  -n, --name=NAME    name option
EOF

expectedOptions[name]="foo:bar"
runTest -nfoo:bar <<EOF
  -n, --name=NAME    name option
EOF

expectedOptions[a]=true
expectedOptions[b]=true
expectedArguments=( foo -ab bar --ddd )
runTest -ab foo -- -ab bar --ddd <<EOF
  -a           option a
  -b           option b
  -c           option c
  -d, --ddd    option d
EOF

expectedOptions[a]=true
expectedOptions[b]=true
expectedArguments=( foo -ab bar --ddd )
runTest --shebang -ab foo -- -ab bar --ddd <<EOF
  -a           option a
  -b           option b
  -c           option c
  -d, --ddd    option d
EOF

expectedOptions[a]=true
expectedOptions[b]=true
expectedArguments=( foo -ab bar --ddd )
runTest '--shebang -ab foo -- -ab bar --ddd' <<EOF
  -a           option a
  -b           option b
  -c           option c
  -d, --ddd    option d
EOF

expectedOptions[a]=true
expectedOptions[b]=true
expectedArguments=( foo -ab more-than-one --ddd )
runTest '--shebang -ab foo -- -ab' more-than-one --ddd <<EOF
  -a           option a
  -b           option b
  -c           option c
  -d, --ddd    option d
EOF

expectedOptions[tags]=foo,bar
runTest -t foo -t bar <<EOF
  -t, --tags=TAG,[TAG,...]   multiple tags
EOF


expectedOptions[debug]=true
runTest --debug <<EOF
  --debug   DEBUG
EOF

expectedOptionsError=('Invalid option "--invalid-option".')
runTest --invalid-option <<EOF
  -v, --version    show version
EOF

expectedOptionsError=('Option "--tags" requires an argument.')
runTest --tags <<EOF
  -t, --tags=TAG,[TAG,...]   tags
EOF

expectedOptionsError=('Option "-t" requires an argument.')
runTest -t <<EOF
  -t, --tags=TAG,[TAG,...]   tags
EOF

expectedOptionsError=('Invalid option "--invalid-option".'
                      'Invalid option "--another-invalid-option".')
runTest --invalid-option --another-invalid-option <<EOF
  -v, --version    show version
EOF

expectedOptionsError=('Invalid option "-a".'
                      'Invalid option "-b".'
                      'Invalid option "--the-third-invalid-option".')
runTest -ab --the-third-invalid-option <<EOF
  -v, --version    show version
EOF

########################
#
help_message="
Usage: foobar [OPTION]... [SCRIPT]...
foobar is an application, $(date +%F\ %T)

Mandatory arguments to long options are mandatory for short options too
  -d, --domain=DOMAIN_NAME   set the dynamic domain DOMAIN
  -l, --login                log in to the vm after started up
  -m, --machine=MACHINE_TYPE  the machine type, (n1-standard-1 if omit)
      --os-image=OS-IMAGE    the OS image used for creating the vm
  -S                         sort by file size, largest first
  -T, --timeout=TIMEOUT      the script must be finnished within TIMEOUT seconds
  -t, --tags=TAG[,TAG,...]   add tags to the instance
  -s STAMP                   use [[CC]YY]MMDDhhmm[.ss] instead of current time
                             if there are some zones starts with ZONE,
                             a random mached zone will be selected.
  -h, --help     display this help and exit
  -v, --version  output version information and exit

Exit status:
 0  if OK,
 1  if minor problems
 2  if serious trouble (e.g., cannot create a vm).
"

function show_help() {
  echo "$help_message"
}


declare -a testopts=(
  "--domain=tyjie.com"
  foobar
  "--os-image=ubuntu-18.04"
  "--machine" "'vmname'"
  -S
  -T 60
  -s"$(date +%s)"
  "--tags=https-server"
  -thttp-server
  --tags squid-server
  -t "\"socks5-server\\\""
  -l
)

declare -A OPTIONS=()
OPTIONS[login]=false
OPTIONS[help]=false
OPTIONS[debug]=false
OPTIONS[timeout]=300
OPTIONS[os-image]=ubuntu-16.04
OPTIONS[machine]=n1-standard-1

declare -A expectedOptions=()
expectedOptions[S]=true
expectedOptions[debug]=false
expectedOptions[domain]=tyjie.com
expectedOptions[help]=false
expectedOptions[login]=true
expectedOptions[machine]=\''vmname'\'
expectedOptions[os-image]=ubuntu-18.04
expectedOptions[s]=1554252965
expectedOptions[tags]=https-server,http-server,squid-server,\"socks5-server\\\"
expectedOptions[timeout]=60

declare -a expectedArguments=( foobar )
gnu_generic_getopts show_help "${testopts[@]}" || printf "Error: %s\n" "${OPTIONS_ERROR[@]}" >&2
assert_gnu_generic_getopts "${testopts[*]}"


declare -A OPTIONS=( )
OPTIONS[login]=false
OPTIONS[help]=false
OPTIONS[debug]=false
OPTIONS[timeout]=300
OPTIONS[os-image]=ubuntu-16.04
OPTIONS[machine]=n1-standard-1

declare -A expectedOptions=()
expectedOptions[S]=true
expectedOptions[debug]=false
expectedOptions[domain]=tyjie.com
expectedOptions[help]=false
expectedOptions[login]=true
expectedOptions[machine]=\''vmname'\'
expectedOptions[os-image]=ubuntu-18.04
expectedOptions[s]=1554252965
expectedOptions[tags]=https-server,http-server,squid-server,\"socks5-server\\\"
expectedOptions[timeout]=60

declare -a expectedArguments=( foobar )
gnu_generic_getopts show_help "--shebang ${testopts[*]}" || printf "Error: %s\n" "${OPTIONS_ERROR[@]}" >&2
assert_gnu_generic_getopts "${testopts[*]}"

printf "%.1s" "="{1..60}
printf '\nTesting DONE: Total: %d, failed: %d.\n' "$testsCount" "$testsFailed"
printf "%.1s" "="{1..60}
echo

# vi: set shiftwidth=2 :
# vi: set tabstop=2 :
