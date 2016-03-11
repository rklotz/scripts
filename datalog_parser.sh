#!/bin/ksh
#
# Created on 11/2/2011 by Rob Klotz
# This script will be used to parse the RMM Receiver information in the /opt/gts/var/log/datalog file
# and will generate alerts based upon the folling criteria
# 1) If the allocated recvbuffer reaches 70% of the Max allowed

# A Shell function to print a error message and exit the script
error_and_die ()
{
echo "$@" >&2
exit 1
}

# A Shell function to priint an error message and exit the script with usage
error_and_die_with_usage ()
{
echo "
$@" >&2
usage
exit 1
}

# A Shell function to print a usage message
usage ()
{
echo "
Usage: datalog_parse.ksh filename(s)
Note this script Supports wilcards for filename expansion
" >&2
}

if [ ! "$1" ]

	then
	error_and_die_with_usage "Please provide an input file(s)"
fi

typeset -i section_start=0

read_section ()
     	{
     	typeset -i done=0

     # find the first starting point
     while :
         do
         read line || return 1
         case $line in
         *"RMM Receiver SnapShot Report End"*)
                 # starting or ending
                 if [ $section_start -eq 0 ]
               then
                     typeset -i section_start=1
                 else
                     return 0
                     fi
                ;;
         *"RMM Receiver Snapshot Report ("*)
                 : # throw away line
                 ;;
         *20[0-9][0-9]-[0-9][0-9]-[0-9[0-9]*)
                 Date_line=$line
                 ;;
         *Instance:*)
                 Instance_line=$line
                 ;;
         *"TaskTimer: nLoops:"*)
                 TaskTime_Line=$line
                 ;;
         *"Socket: nCall:"*)
                 Socket_line=$line
                 ;;
         *"Throuput: TotPacksIn:"*)
                 Throuput_ToPacksIn_line=$line
                 ;;
         *"Throuput: Rate:"*)
                 Throuput_Rate_line=$line
                 ;;
         *"recvBuffs:"*)
                 recvBuffs_line=$line
                 ;;
         *"nackElmnts:"*)
                 nackElmnts_line=$line
                 ;;
         *"PackCount:"*)
                 PackCount_line=$line
                 ;;
         esac
         done

     	}

cd /home/gtsman/scripts/tmp	# CD into the Datalog directory

for file  # Supports multiple files via wildcard

 do

typeset -i done=0

	sed -e '/^[      ]*$/d' "$file" | while [ $done -eq 0 ]	# Use sed to strip out empty lines, loop until the file is fully read

		do

		if read_section

			then
			# for each of the sections in the file, you have this information in
			# shell variables, now you can use it for processing
			#	print -- "$Date_line"
			#	print -- "$Instance_line"
			#	print -- "$TaskTime_Line"
			#	print -- "$Socket_line"
			#	print -- "$Throuput_ToPacksIn_line"
			#	print -- "$Throuput_Rate_line"
			#	print -- "$recvBuffs_line"
			#	print -- "$nackElmnts_line"
			#	print -- "$PackCount_line"
			typeset -i maxbuffer=$(echo $recvBuffs_line | cut -d: -f7 | sed -e 's/^[ \t]*//' -e 's/ .*$//')
			typeset -i allocated=$(echo $recvBuffs_line | cut -d: -f3 | sed -e 's/^[ \t]*//' -e 's/ .*$//')
			typeset -i threshold=$((70.00/100.00*maxbuffer))
			date_time=$(echo $Date_line | cut -c1-19 | sed 's/TO*/ /g')
			log_date=$(echo $Date_line | cut -c1-10)
			today=$(date +%Y-%m-%d)
			process_instance=$(echo $Date_line | cut -c34-49)

				if [ $allocated -ge $threshold -a $log_date -eq $today ]

					then
					echo "Alert: $process_instance RMM receiver exceeded the 70% allocated buffer threshold at $date_time "
				fi

			else
      			typeset -i done=1

		fi
	done
done
