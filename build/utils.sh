#!/bin/bash

# Creates intermediate dirs of given file path
# 
# local_file_path - rel path to nested file (i.e., expects at least 1 intermediate dir, otherwise
#                   file name will be erroneously created as dir)
make_dirs() {
    mkdir -p "${local_file_path%/*}"
}

replace_file() {    
    # if not OVERWRITE, backup local file
    if [ $OVERWRITE -eq 0 ]; then
        echo -n '        backup: '
        {
            file_name=$(echo $file_path | tr / "\n" | tail -n 1)
            # define backup_path as path to cooresponding local hidden file with unique suffix
            backup_path=${local_file_path%/*}/.${file_name#.}.$$.bak
            
            # perform backup
            mv "$local_file_path" "$backup_path"
            ((backups++))
            echo $backup_path
        
        } || handle_failure
    fi
    
    install_file
}

install_file() {
    echo -n '        install: '
    {
        cp "$file_path" "$local_file_path"
        ((installs++))
        echo $local_file_path
    
    } || handle_failure
}

disable_service() {
    echo -n "        disable $local_service: "
    {
        mv "$local_service" "$local_service_disabled"
        echo done
    
    } || handle_failure 
}


# helpers ==================================================================== #

print_file_path() {
    echo "    $file_path"
}

handle_failure() {
    echo FAILED
    ((failures++))
}

# ========================= # 


# statistics ================================================================= #

_STATS=(installs backups failures)


init_stats() {
    for stat in ${_STATS[@]}; do
        declare -g -i $stat=0
    done
}

print_stats() {
    for stat in ${_STATS[@]}; do
        echo -n "${!stat} "
    done
    echo
}

parse_log() {
    echo "$log" | head -n -1
    log_stats=$(echo "$log" | tail -n 1)
    i=1
    for stat in ${_STATS[@]}; do
        declare -g -i $stat=$((${!stat} + $(echo $log_stats | cut -d ' ' -f$i)))
        ((i++))
    done
}

# ========================= # 
