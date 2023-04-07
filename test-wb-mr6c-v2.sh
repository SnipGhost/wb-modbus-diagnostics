#!/bin/bash

. setup_modbus.sh

for slave_id in "$@"
do
	check_device $slave_id
	check_device_model $slave_id "WBMR6C"
	print_device_info $slave_id

	# Save current mode:
	save_mode=$($MBC -a $slave_id -t $CMD_READ_HOLDING_REGISTERS -r 6 | grep Data | sed -e 's/.*Data: //' | tr -d ' ')
	echo -e "Mode:     [${save_mode}]"

	# Set simple mode:
	echo "Set mode 1 (Restore previous channel states)"
	$MBC -a $slave_id -t $CMD_WRITE_SINGLE_REGISTER -r 6 1

	states=()
	# Save outputs and set type
	for register in 9 10 11 12 13 14
	do
		echo "Save state of register $register & set output mode (button)"
		states[$register]=$($MBC -a $slave_id -t $CMD_READ_HOLDING_REGISTERS -r $register | grep Data | sed -e 's/.*Data: //' | tr -d ' ')
		$MBC -a $slave_id -t $CMD_WRITE_SINGLE_REGISTER -r $register 0
		channel=$((register - 9))
		echo "Enable channel $channel"
		$MBC -a $slave_id -t $CMD_WRITE_SINGLE_COIL -r $channel 1
		sleep $DELAY
	done

        # Reset outputs
        for register in 9 10 11 12 13 14
        do
                channel=$((register - 9))
                echo "Disable channel $channel"
                $MBC -a $slave_id -t $CMD_WRITE_SINGLE_COIL -r $channel 0
                sleep $DELAY
		echo "Set previous state of register $register"
		$MBC -a $slave_id -t $CMD_WRITE_SINGLE_REGISTER -r $register ${states[register]}
        done

	# Beep as end of "input" tests
	beep

	# Set previous mode
	$MBC -a $slave_id -t $CMD_WRITE_SINGLE_REGISTER -r 6 $save_mode
done
