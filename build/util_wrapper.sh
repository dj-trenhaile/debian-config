#!/bin/bash
_DIR=${BASH_SOURCE%/*}
source ${_DIR}/utils.sh
CMD=$1


init_stats
eval $CMD
print_stats

