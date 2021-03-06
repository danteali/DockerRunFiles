#!/bin/bash

    red=`tput setaf 1`
    green=`tput setaf 2`
    yellow=`tput setaf 3`
    blue=`tput setaf 4`
    magenta=`tput setaf 5`
    cyan=`tput setaf 6`
    under=`tput sgr 0 1`
    reset=`tput sgr0`



   
# Analyse docker volumes etc
# Details of various commands used below:
#   tr ' ' '\n' = split into separate lines using ' ' as delimiter
#   sed '/bind\|true.../d' = delete lines containing these strings (can add more)
#   sed 's/\:ro\|:rw//g' = delete these strings from output (can add more)
#   sed '/^$/d' = delete empty lines
#   sed -n '0~2!p' = keep every 2nd line
#   sed 's/^/    /' = adds spaces in front of command output (indenting)
#   sed 's/^.....//' = remove leading characters (replace with . which equals nothing)
#   sed 's|[,) ]||g' = remove all chars between [ ]
#   tr -d [ = delete '[' character


# For use if setting up file to take a container name as argument
if [[ -z $1 ]]; then
    echo "No container specified!"
    exit
else
    # Check running as root - attempt to restart with sudo if not already running with root
    if [ $(id -u) -ne 0 ]; then tput setaf 1; echo "Not running as root, attempting to automatically restart script with root access..."; tput sgr0; echo; sudo $0 $*; exit 1; fi

    echo ""
    echo "${cyan}=================================================================================================================="

    d_name=$1
    d_id=$(docker inspect -f {{.Id}} $d_name)
    d_id_short=$(echo $d_id | head -c 12)
    #d_name=`docker inspect -f {{.Name}} $d_id_short | sed 's/^.//'` 
    d_logpath=`docker inspect -f {{.LogPath}} $d_id_short`

    echo ""
    echo "CONTAINER: ${green}$d_name ${cyan}(${green}$d_id_short${cyan})"
    echo ""
    echo "------------------------------------------------------------------------------------------------------------------"
    echo ""
    echo "${magenta}DOCKER-MANAGED STORAGE SIZE ${magenta}(${green}$d_name${magenta})"
    # Get sizes of all container dirs then grep for our one
        #sudo du -c -d 2 -h /var/lib/docker/containers | \
        #    grep `docker inspect -f "{{.Id}}" $d_id_short` | \
        #    sed 's/^/    /'
    # Better way instead is to use our container ID in the command to get only it's info
    sudo du -c -d 1 -h /var/lib/docker/containers/$d_id | \
        sed 's/^/    /'
    

    echo ""
    echo "${yellow}LOGFILE SIZES (${green}$d_name${yellow})"
    echo "[also included in docker-managed storage above]"
    sudo du -c -d 1 -h /var/lib/docker/containers/$d_id/*.log | \
        sed 's/^/    /'
        
    echo ""
    echo "${blue}LIST USER-DEFINED VOLUMES (${green}$d_name${blue})"
    echo "[manually check sizes if needed]"
    # This gets the local mapping locations only
        #docker inspect -f "{{.Mounts}}" $d_id_short | \
        #    tr ' ' '\n' | \
        #    sed '/bind\|true\|false\|ro\|rw\|{\|}\|\/dev\|localtime/d' | \
        #    sed '/^$/d' | \
        #    sed -n '0~2!p' | \
        #    sed 's/^/    /'
    # Get both sides of mapping
        docker inspect -f "{{.HostConfig.Binds}}" $d_id | \
            tr ' ' '\n' | \
            sed 's/\:ro\|:rw//g' | \
            tr -d [ | \
            tr -d ] | \
            sed 's/:/\n     ----\> /g' | \
            sed 's/^/    /'

    echo ""
    echo "${cyan}=================================================================================================================="


echo ""
echo "${magenta}=================================================================================================================="
echo ""
echo "CONTAINER LOG SIZES SUMMARY${yellow}"
echo ""
printf "%-10s %35s %12s\n" "LOG SIZE" "CONTAINER" "ID (short)"

TOTALSIZE_K=0
echo " ${yellow}"
sudo sh -c "du -sk /var/lib/docker/containers/*/*-json.log" | sort -rn | while read -r line ; do

    SIZE_K=$(echo $line | awk '{print $1}')
    SIZE_H=$(numfmt --from-unit=K --to=si --format %.1f $SIZE_K)
    TOTALSIZE_K=$(($TOTALSIZE_K + $SIZE_K))

    LOGPATH=$(echo $line | awk '{print $2}')
    LOGFILE=$(basename "$LOGPATH")
    ID=$(echo $LOGFILE | sed 's/.........$//')
    ID_SHORT=$(echo $ID | head -c 12)
    CONTAINER_NAME=$(docker inspect -f {{.Name}} $ID | sed 's/^.//')
    
    printf "%-10s %35s %12s\n" "$SIZE_H" "$CONTAINER_NAME" "$ID_SHORT"
    
done

TOTALSIZE_H=$(numfmt --from-unit=K --to=si --format %.1f $TOTALSIZE_K)
#echo "TOTAL SIZE: $TOTALSIZE_H"


echo ""
echo "${magenta}=================================================================================================================="
echo ""


fi


