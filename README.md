Common Functions Library
========================

[![Build Status](https://travis-ci.org/chaifeng/shell-common-functions-library.svg)](https://travis-ci.org/chaifeng/shell-common-functions-library/)

## Requires

- Bash v4.3+
- Zsh v5.3+

## Usage

Put the following line at the begining of your script:

    export CFLIB_INC_PATH='/path/to/common-functions-lib'; source "$CFLIB_INC_PATH/cflib-import.sh"

## Bach Testing Framework

[Bach](https://bach.sh) is a unit testing framework for Bash

### Requires

- Bash v4.3+

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
                        # DO NOT PANIC! By using Bach Testing Framework it won't actually run.
    }

    test-rm-your-dot-git() {
        # Mock `find` command with certain parameters, will output two directories

        @mock find ~ -type d -name .git === @stdout ~/src/your-awesome-project/.git \
                                                    ~/src/code/.git

        # Do it, remove all .git directories
        find ~ -type d -name .git | xargs -- rm -rf
    }
    test-rm-your-dot-git-assert() {
        # Verify the actual command

        rm -rf ~/src/your-awesome-project/.git ~/src/code/.git
    }


[More Examples: examples/test-bach-unit-testing-framework.sh](examples/test-bach-unit-testing-framework.sh)
    
## Functions

### die
### err
### require
### gnu_generic_getopts

see the script `examples/test_gnu_generic_getopts.sh`
