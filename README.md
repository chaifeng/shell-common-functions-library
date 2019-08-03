Common Functions Library
========================

## Usage

Put the following line at the begining of your script:

    export CFLIB_INC_PATH='/path/to/common-functions-lib'; source "$CFLIB_INC_PATH/cflib-import.sh"
    
## Functions

### die
### err
### require
### gnu_generic_getopts

see the script `examples/test_gnu_generic_getopts.sh`

## Bach Testing Framework

[Bach](lib/bach/) is a unit testing framework for Bash

It's part of Shell Common Functions Library

### Examples

    #!/usr/bin/env bash
    set -euo pipefail
    source <(path/to/common-functions-lib/cflib-import.sh)
    require bach

    test-rm-rf() {
        # Write your test case

        project_log_path=/tmp/project/logs
        sudo rm -rf "$project_log_ptah/" # Typo here!
    }
    test-rm-rf-assert() {
        # Verify your test case
        sudo rm -rf /   # This is the actual command to run on your host!
                        # DO NOT worry! By using Bach Testing Framework it won't actually run.
    }
