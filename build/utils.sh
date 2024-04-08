#!/bin/bash

# **NOTE: ineffective on file_paths in which the file is the only path 
# component (no trailing slash to remove, so file name will be interpretted as
# dir name to create)
make_dirs() {
    mkdir -p ${local_file_path%/*}
}

replace_file() {    
    if [ $OVERWRITE -eq 0 ]; then
        echo -n "        backup: "   
        {
            file_name=$(echo $file_path | tr '/' '\n' | tail -n 1)
            backup_path=${local_file_path%/*}/.${file_name#.}.$$.bak
            mv $local_file_path $backup_path
            backups=$((backups+1))
            echo $backup_path
            
            install_file
        } || handle_failure
    else
        install_file
    fi
}

install_file() {
    echo -n "        install: "
    {
        cp $file_path $local_file_path
        installs=$((installs+1))
        echo $local_file_path
    } || handle_failure
}

disable_service() {
    echo -n "        disable ${local_service}: "
    {
        mv $local_service $local_service_disabled
        echo done
    } || handle_failure 
}


# helpers ==================================================================== #
print_file_path() {
    echo "    $file_path"
}

handle_failure() {
    echo FAILED
    failures=$((failures+1))
}



# statistics ================================================================= #
STATS=("installs" "backups" "failures")


init_stats() {
    for stat in ${STATS[@]}; do
        declare -g -i $stat=0
    done
}

print_stats() {
    for stat in ${STATS[@]}; do
        echo -n "${!stat} "
    done
    echo
}

parse_log() {
    echo $log | head -n -1
    log_stats=$(echo $log | tail -n 1)
    i=1
    for stat in ${STATS[@]}; do
        declare -g -i $stat=$((${!stat} + $(echo $log_stats | cut -d ' ' -f$i)))
        i=$((i+1))
    done
}
