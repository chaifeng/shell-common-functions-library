#!/usr/bin/env bash

eval "$("${0%/*}/../cflib-import.sh")"

declare -A OPTIONS
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
  local name="${*}"
  local -i retval=0
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
  if [[ $retval -eq 0 ]]; then
    success "$name"
  else
    error "FAILED: $name"
  fi
  return $retval
)

declare -i testsCount=0 testsFailed=0

function runTest() {
  local help_msg
  help_msg="$(cat)"
  unset OPTIONS ARGUMENTS
  gnu_generic_getopts - "$@" <<< "$help_msg" || error "Invalid option"
  if assert_gnu_generic_getopts "$@"; then
    : $(( testsCount++ ))
  else
    : $(( testsFailed++ ))
  fi
  unset expectedOptions expectedArguments
} &>/dev/null

unset OPTIONS

#############################################################################
#                                TEST CASES
#############################################################################

declare -A expectedOptions=( )
declare -a expectedArguments=( )
runTest <<EOF
EOF

declare -A expectedOptions=( [help]=true )
declare -a expectedArguments=( --foo foobar --bar )
runTest --help --foo foobar --bar <<EOF
EOF

declare -A expectedOptions=( [version]=true )
declare -a expectedArguments=( )
runTest --version <<EOF
  -v, --version    show version
EOF

declare -A expectedOptions=( [version]=true )
declare -a expectedArguments=( )
runTest -v <<EOF
  -v, --version    show version
EOF

declare -A expectedOptions=( [v]=true )
declare -a expectedArguments=( )
runTest -v <<EOF
  -v      show version
EOF

declare -A OPTIONS=( [verbose]=true )
declare -A expectedOptions=( [verbose]=false )
declare -a expectedArguments=( )
runTest --verbose=no <<EOF
  -V, --verbose      verbose option
EOF

declare -A expectedOptions=( [version]=true )
declare -a expectedArguments=( )
runTest --version=yes <<EOF
  -v, --version      show version
EOF

declare -A expectedOptions=( [version]=true )
declare -a expectedArguments=( )
runTest --version <<EOF
  --version      show version
EOF

declare -A expectedOptions=( [t]=true )
declare -a expectedArguments=( )
runTest -t <<EOF
  -t
EOF

declare -A expectedOptions=( [tab]=true )
declare -a expectedArguments=( )
runTest --tab <<EOF
  --tab
EOF

declare -A expectedOptions=( [tab]=true )
declare -a expectedArguments=( )
runTest -t <<EOF
  -t, --tab
EOF

declare -A expectedOptions=( [n]=tom )
declare -a expectedArguments=( )
runTest -n tom <<EOF
  -n NAME
EOF

declare -A expectedOptions=( [name]="Tom Hanks" )
declare -a expectedArguments=( )
runTest --name "Tom Hanks" <<EOF
  --name=NAME
EOF

declare -A expectedOptions=( [name]="Tom Hanks" )
declare -a expectedArguments=( )
runTest -nTom\ Hanks <<EOF
  -n, --name=NAME
EOF

declare -A expectedOptions=( [t]=true )
declare -a expectedArguments=( )
runTest -t <<EOF
  -t	short option, allow using tab to split
EOF

declare -A expectedOptions=( [tab]=true )
declare -a expectedArguments=( )
runTest --tab <<EOF
  --tab	long option, allow using tab to split
EOF

declare -A expectedOptions=( [tab]=true )
declare -a expectedArguments=( )
runTest -t <<EOF
  -t, --tab	allow using tab to split
EOF

declare -A expectedOptions=( [n]=tom )
declare -a expectedArguments=( )
runTest -n tom <<EOF
  -n NAME	short option, allow using tab to split
EOF

declare -A expectedOptions=( [name]="Tom Hanks" )
declare -a expectedArguments=( )
runTest --name "Tom Hanks" <<EOF
  --name=NAME	long option, allow using tab to split
EOF

declare -A expectedOptions=( [name]="Tom Hanks" )
declare -a expectedArguments=( )
runTest -nTom\ Hanks <<EOF
  -n, --name=NAME	allow using tab to split
EOF

declare -A expectedOptions=( [domain]=example.com )
declare -a expectedArguments=( )
runTest --domain example.com <<EOF
  -d, --domain=DOMAIN-NAME    domain name
EOF

declare -A expectedOptions=( [domain]=example.com )
declare -a expectedArguments=( )
runTest -d example.com <<EOF
  -d, --domain=DOMAIN-NAME    domain name
EOF

declare -A expectedOptions=( [domain]=example.com )
declare -a expectedArguments=( )
runTest --domain=example.com <<EOF
  -d, --domain=DOMAIN-NAME    domain name
EOF

declare -A expectedOptions=( [d]=example.com )
declare -a expectedArguments=( )
runTest -d example.com <<EOF
  -d DOMAIN-NAME    domain name
EOF

declare -A expectedOptions=( [d]=example.com )
declare -a expectedArguments=( )
runTest -dexample.com <<EOF
  -d DOMAIN-NAME    domain name
EOF

declare -A expectedOptions=( [domain]=example.com )
declare -a expectedArguments=( )
runTest --domain=example.com <<EOF
  --domain=DOMAIN-NAME    domain name
EOF

declare -A expectedOptions=( [domain]=example.com )
declare -a expectedArguments=( )
runTest -dexample.com <<EOF
  -d, --domain DOMAIN-NAME    domain name, using a single space
EOF

declare -A expectedOptions=( [domain]=example.com )
declare -a expectedArguments=( )
runTest --domain=example.com <<EOF
  --domain DOMAIN-NAME    domain name, using a single space
EOF

declare -A expectedOptions=( [tags]=foo )
declare -a expectedArguments=( )
runTest --tags=foo <<EOF
  --tags=TAG,[TAG,...]   multiple tags
EOF

declare -A expectedOptions=( [tags]=foo,bar )
declare -a expectedArguments=( )
runTest --tags=foo,bar <<EOF
  --tags=TAG,[TAG,...]   multiple tags
EOF

declare -A expectedOptions=( [tags]=foo,bar )
declare -a expectedArguments=( )
runTest --tags=foo --tags bar <<EOF
  --tags=TAG,[TAG,...]   multiple tags
EOF

declare -A expectedOptions=( [tags]=foo,bar )
declare -a expectedArguments=( )
runTest -t foo --tags bar <<EOF
  -t, --tags=TAG,[TAG,...]   multiple tags
EOF

declare -A expectedOptions=( [user]=bar:secret )
declare -a expectedArguments=( )
runTest -u foo --user bar:secret <<EOF
  -u, --user=USER[:PASSWORD]    Server user and password
EOF

declare -A expectedOptions=( [user]=bar )
declare -a expectedArguments=( )
runTest -ubar <<EOF
  -u, --user=USER[:PASSWORD]    Server user and password
EOF

declare -A expectedOptions=( [a]=true [b]=true )
declare -a expectedArguments=( )
runTest -a -b <<EOF
  -a   option a
  -b   option b
EOF

declare -A expectedOptions=( [a]=true [b]=true )
declare -a expectedArguments=( )
runTest -ab <<EOF
  -a   option a
  -b   option b
EOF

declare -A expectedOptions=( [a]=true [b]=true )
declare -a expectedArguments=( -c -d )
runTest -ab -- -c -d <<EOF
  -a   option a
  -b   option b
  -c   option c
  -d   option d
EOF

declare -A expectedOptions=( [a]=true [b]=true )
declare -a expectedArguments=( -ab -cd )
runTest -ab -- -ab -cd <<EOF
  -a   option a
  -b   option b
  -c   option c
  -d   option d
EOF

declare -A expectedOptions=( [name]="foo bar" )
declare -a expectedArguments=( )
runTest -n"foo bar" <<EOF
  -n, --name=NAME    name option
EOF

declare -A expectedOptions=( [name]="foo:bar" )
declare -a expectedArguments=( )
runTest -nfoo:bar <<EOF
  -n, --name=NAME    name option
EOF

declare -A expectedOptions=( [a]=true [b]=true )
declare -a expectedArguments=( foo -ab bar --ddd )
runTest -ab foo -- -ab bar --ddd <<EOF
  -a           option a
  -b           option b
  -c           option c
  -d, --ddd    option d
EOF

declare -A expectedOptions=( [a]=true [b]=true )
declare -a expectedArguments=( foo -ab bar --ddd )
runTest --shebang -ab foo -- -ab bar --ddd <<EOF
  -a           option a
  -b           option b
  -c           option c
  -d, --ddd    option d
EOF

declare -A expectedOptions=( [a]=true [b]=true )
declare -a expectedArguments=( foo -ab bar --ddd )
runTest '--shebang -ab foo -- -ab bar --ddd' <<EOF
  -a           option a
  -b           option b
  -c           option c
  -d, --ddd    option d
EOF

declare -A expectedOptions=( [tags]=foo,bar )
declare -a expectedArguments=( )
runTest -t foo -t bar <<EOF
  -t, --tags=TAG,[TAG,...]   multiple tags
EOF


declare -A expectedOptions=( [debug]=true )
declare -a expectedArguments=( )
runTest --debug <<EOF
  --debug   DEBUG
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
gnu_generic_getopts show_help "${testopts[@]}" || error "Found error"
assert_gnu_generic_getopts "${testopts[*]}"



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
gnu_generic_getopts show_help "--shebang ${testopts[*]}" || error "Found error"
assert_gnu_generic_getopts "${testopts[*]}"

printf "%.1s" "="{1..60}
printf '\nTesting DONE: Total: %d, failed: %d.\n' "$testsCount" "$testsFailed"
printf "%.1s" "="{1..60}
echo

# vi: set shiftwidth=2 :
# vi: set tabstop=2 :
