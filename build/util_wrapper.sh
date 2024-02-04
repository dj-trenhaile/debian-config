#!/bin/bash
_DIR=${BASH_SOURCE%/*}
CMD=$1


source ${_DIR}/utils.sh

init_stats
eval $CMD
print_stats
