#!/bin/bash

. setup_modbus.sh

min_level=30
levels=(40 43 45)

for slave_id in "$@"
do
	check_device $slave_id
	check_device_model $slave_id "WBMD3"
	print_device_info $slave_id

	for channel in 0 1 2
	do
		echo "Enable channel $channel with mininal brightness level"
		$MBC -a $slave_id -t $CMD_WRITE_SINGLE_REGISTER -r $channel $min_level
		$MBC -a $slave_id -t $CMD_WRITE_SINGLE_COIL -r $channel 1
		sleep $DELAY

		# Test multiple brightness levels
		for level in ${levels[*]}
		do
			echo "Set channel $channel brightness to $level"
			$MBC -a $slave_id -t $CMD_WRITE_SINGLE_REGISTER -r $channel $level
			sleep $DELAY
		done

		echo "Disable channel $channel"
		$MBC -a $slave_id -t $CMD_WRITE_SINGLE_COIL -r $channel 0
	done

	# Beep as end of "input" tests
        beep
done
