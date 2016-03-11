#!/bin/bash
##################################################################################################################################
# Author: Robert Klotz
# makesnap ­­ take a snapshot of a given logical volume and deleteny older than rotate_count
# usage: makesnap <logicalvol> <rotate_count>
#
################################################################################################################################## 


function help_me
{
 echo
 echo "makesnap has the following usage"
 echo "<logicalvol> the name of the volume to take a snap of"
 echo "<rotate_count> - the maximum number of snap's at a time"
 echo
 exit 1
}

function snap_error

{
 echo
 echo "There was an error creating the snapshot volume, Please investigate"
 exit 1
}

function removal_failure
{
 echo
 echo " There was a failure removing the old snap files, Please investigate"
 exit 1
}


logical_vol=$1     
declare -i rotate_count=$2

if [ -z "$1" ]; # Test to see if the first positional parameter is null. 
        then
                echo " Please check your usage"
                echo
                help_me
        fi

# Test that $1 is a valid block device file

if [ ! -b /dev/$1 ];
        then
                echo " Please specify a valid logical volume"
                echo
                help_me
        fi

# Test that $1 is a valid logical volume in LVM

sudo lvdisplay $logical_vol >> /dev/null || help_me

# Test that $2 is an integer
test -z $(echo "$rotate_count" | sed s/[0-9]//g) || help_me

# Ensure sufficient diskspace exists

declare -i snap_size=`sudo lvdisplay $logical_vol | awk '/LV Size/ { print $3 }' | cut -d . -f1`  

declare -i free_space=`sudo vgdisplay | grep Free | awk '{print $7}' | cut -d . -f1`  # Capture free space in the volume

if [ $snap_size -gt $free_space ]; # Compare free space in the volume against the snapshot size, exit if there is insufficient space

        then
        echo
        echo " You do not have enough free space for the snap. Please allocate more space to the volume"
        logger daemon.notice "Not enough space to make snap ${logical_vol}-snap_`date +%y-%m-%d-%s`"
        help_me
fi

# Create the snapshot
sudo lvcreate -s -L ${snap_size}M -n ${logical_vol}-snap_`date +%y-%m-%d-%s` $logical_vol || snap_error
logger daemon.notice "Snapshot of ${logical_vol} taken"


# Cleanup old snaps if that number exceeds the rotate count

declare -i existing_snaps=`ls -lt /dev/${logical_vol}-snap* | wc -l`


while [ $existing_snaps -gt $rotate_count ]; do
        oldest=`ls -lt /dev/${logical_vol}-snap* | tail -n 1 | cut -d' ' -f9 | sed 's/\/dev\///'`
        echo "Removing $oldest"
        sudo lvremove -f $oldest || removal_failure 
        declare -i existing_snaps=`ls -lt /dev/${logical_vol}-snap* | wc -l`
done


exit
