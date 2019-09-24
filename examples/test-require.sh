#!/usr/bin/env bash
set -x
source <("$(cd "$(dirname "$BASH_SOURCE")"; pwd -P)"/../cflib-import.sh)
require bach

@setup {
    CFLIB_INC_PATH=.
    lib="$CFLIB_INC_PATH"/lib
    @mkdir "$lib"
}

@setup-test {
    @mock source
    @load_function "${self%/*/*}/functions/require" require
}

test-requires-a-file-in-lib() {
    @touch "$lib/beta"

    require beta
}
test-requires-a-file-in-lib-assert() {
    @dryrun source ./lib/beta
}


test-requires-a-folder-in-lib() {
    @mkdir -p "$lib/foobar"
    @touch "$lib"/foobar/foobar.sh

    require foobar
}
test-requires-a-folder-in-lib-assert() {
    @dryrun source ./lib/foobar/foobar.sh
}


test-requires-a-folder-with-multi-files-in-lib() {
    @mkdir -p "$lib/foobar"
    @touch "$lib"/foobar/{readme.txt,alpha.sh,zoo.sh,foobar.sh}

    require foobar
}
test-requires-a-folder-with-multi-files-in-lib-assert() {
    @dryrun source ./lib/foobar/foobar.sh
}
