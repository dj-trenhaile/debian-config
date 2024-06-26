#!/bin/bash
source "${BASH_SOURCE%/*}/utils.sh"

CMD=$1


init_stats
eval $CMD
print_stats
