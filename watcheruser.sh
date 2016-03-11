#!/bin/bash
#########################################################################################
# Author: Rob Klotz
# Created: 6/18/15
# Last Modified date:
# Description: The watchuser tool displays how long login sessions of the given username
# has existed in seconds. If -s is given, it is repeated every second
# forever. Otherwise it runs once. The username is a mandatory argument.
##########################################################################################



function help_me
{
        echo "watchuser accepts the following command line options"
        echo
        echo "Optional : -s will allow watchuser to repeat every second forever"
        echo
        echo " usage: ./watchuser -s <username>"
        echo
}


function illegal_argument
{
        echo "Illegal argument, watchuser accepts the following arguments"
        echo
        echo "Optional : -s will allow watchuser to repeat every second forever"
        echo
        echo "usage: ./watchuser -s <username>"
        echo
}

function invalid_user
{
        echo
        echo " The user you have provided is either invalid or has logged off the system"
        echo
        exit 1
}

# Check to see if any arguments are passed. Show help if nothing  is passed"
#
#
 if [ -z "$1" ]; # Test to see if the first positional parameter is null, provide help if it is
        then
                echo
                help_me && exit 0
        fi

if [ $# -eq 2 ] && [ $1 = "-s" ] ; then # test to see how many arguments are provided

        while true ; do

                #confirm that $2 is a valid user
                who | grep -E "^${2}\s" > /dev/null
                if [ $? -eq 1 ]
                        then
                                invalid_user
                fi

                # the line below grabs the users login time
                usr_login=`who | grep "$2" | awk '{print " "$3" "$4" "}'`;

                # Now convert the user login time to an epoch format
                epoch=`date --date="$usr_login" "+%s"`

                #Get the current time in epoch format
                current_time=`date +%s`

                # Output the user and time logged in
                echo "User              Time logged on in seconds"
                echo "$2                $(( $current_time - $epoch))"

        sleep 1
        done

elif [ $# -eq 1 ]; then


#confirm that $1 is a valid user
who | grep -E "^${1}\s" > /dev/null

        if [ $? -eq 1 ]
                then
                        invalid_user
        fi

        # the line below grabs the users login time
        usr_login=`who | grep $1 | awk '{print " "$3" "$4" "}'`

        # Now convert the user login time to an epoch format
        epoch=`date --date="$usr_login" "+%s"`

        #Get the current time in epoch format
        current_time=`date +%s`

        # Output the user and time logged in
        echo "User              Time logged on in seconds"
        echo "$1                $(( $current_time - $epoch))"

# Exit with illegal argument if something other than -s is used
elif [ $# -eq 2 ] && [ $1 != "^-s$" ]; then

        illegal_argument && exit 1

fi

exit 0
