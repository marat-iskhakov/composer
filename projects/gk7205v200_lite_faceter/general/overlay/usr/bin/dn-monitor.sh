#!/bin/sh


 : "${again_high_target:=$(fw_printenv -n dn-monitor_again_high)}" "${again_high_target:=90}"
 : "${again_medium_target:=$(fw_printenv -n dn-monitor_again_medium)}" "${again_medium_target:=40}"
 : "${again_low_target:=$(fw_printenv -n dn-monitor_again_low)}" "${again_low_target:=30}"
 : "${exptime_target:=$(fw_printenv -n dn-monitor_exptime)}" "${exptime_target:=900}"

pollingInterval=4
debug=0
nightmode_set=off

nightmode_action(){
	local state="$1"
	curl http://localhost/night/$state && \
	/usr/sbin/irled.sh $state && \
	echo "NIGHT IS: "$state
}


main(){

	echo "...................."
	echo "Watching at isp_again > ${again_high_target} to NIGHT ON"
	echo "Watching at isp_again < ${again_low_target} to NIGHT OFF"
	echo "Polling interval: ${pollingInterval} sec"
	echo "...................."

	sleep 10
	majestic_nightmode=$(cli -g .nightMode.enabled)
	if [ $majestic_nightmode == "true" ] ;then
	    echo "Disabling majestic nightmode..."
	    cli -s .nightMode.enabled false
    	    killall -HUP majestic
	    sleep 10
	fi
	
	nightmode_action "off"

	while true; do
		nightmode_state=$(curl -s http://localhost/metrics | grep ^night_enabled  | cut -d' ' -f2 | head -1)
		if [ -z $nightmode_state ] ; then
		    error=1
		fi

		isp_again=$(curl -s http://localhost/metrics | grep ^isp_again | cut -d' ' -f2 | head -1)
		if [ -z $isp_again ] ; then
		    error=1
		fi

		isp_exptime=$(curl -s http://localhost/metrics | grep ^isp_exptime | cut -d' ' -f2 | head -1)
		if [ -z $isp_exptime ] ; then
		    error=1
		fi

		nightmode_old_set=$nightmode_set

		if [ -z $error ] ; then
		    if [ $isp_again -lt $again_low_target ] && [ $isp_exptime -lt $exptime_target ] && [ $nightmode_state -eq 1 ]  ;then
			    nightmode_set=off
		    fi

		    if [ $isp_again -gt $again_high_target ] && [ $nightmode_state -eq 0 ]  ;then
			    nightmode_set=on
		    fi

		    if [ $isp_again -gt $again_medium_target ] && [ $isp_exptime -gt $exptime_target ] && [ $nightmode_state -eq 0 ]  ;then
			    nightmode_set=on
		    fi
		
		    if [ $nightmode_old_set != $nightmode_set ] ; then
			nightmode_action $nightmode_set
		    fi
		fi
		
		if [ $debug -eq 1 ] ; then
		    echo "isp_again: "$isp_again
		    echo "isp_exptime: "$isp_exptime
		    echo "nightmode_state: "$nightmode_state
		    echo "nightmode_old_set: "$nightmode_old_set
		    echo "nightmode_set: "$nightmode_set
		    echo "...................."
		fi
		
		    sleep ${pollingInterval}
        done
}

main
