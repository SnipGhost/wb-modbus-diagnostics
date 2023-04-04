#!/bin/bash

. setup_modbus.sh

min_level=10
mid_level=40
max_level=70

for slave_id in "$@"
do
	check_device $slave_id
	check_device_model $slave_id "WBLED"
	print_device_info $slave_id

	# Save current mode:
	save_mode=$($MBC -a $slave_id -t $CMD_READ_HOLDING_REGISTERS -r 4000 | grep Data | sed -e 's/.*Data: //' | tr -d ' ')
	echo -e "Mode:     [${save_mode}]"

	# Set simple mode:
	echo "Set mode 0 (W+W+W+W)"
	$MBC -a $slave_id -t $CMD_WRITE_SINGLE_REGISTER -r 4000 0

	# Enable outputs
	for register in 0 1 2
	do
		echo "Enable channel $register"
		$MBC -a $slave_id -t $CMD_WRITE_SINGLE_COIL -r $register 1
		echo "Set channel $register brightness to $max_level"
		$MBC -a $slave_id -t $CMD_WRITE_SINGLE_REGISTER -r "200${register}" $max_level
		sleep $DELAY
		echo "Set channel $register brightness to $mid_level"
		$MBC -a $slave_id -t $CMD_WRITE_SINGLE_REGISTER -r "200${register}" $mid_level
		sleep $DELAY
	done

	# Disable outputs
	for register in 2 1 0
	do
		echo "Set channel $register brightness to $min_level"
		$MBC -a $slave_id -t $CMD_WRITE_SINGLE_REGISTER $min_level
		sleep $DELAY
		echo "Disable channel $register"
		$MBC -a $slave_id -t $CMD_WRITE_SINGLE_COIL -r $register 0
		sleep $DELAY
	done

	# Beep as end of "input" tests
	beep

	# Set previous mode
	$MBC -a $slave_id -t $CMD_WRITE_SINGLE_REGISTER -r 4000 $save_mode
done
