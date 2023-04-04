#!/bin/bash

# Already in .bashrc
MODBUS_UTILS=/root/modbus-utils
#export LD_LIBRARY_PATH="${MODBUS_UTILS}/libmodbus/src/.libs/"

# Modbus settings
BUS=/dev/ttyACM0
BAUD=9600
STOP_BITS=2

# Shortcut
MBC="${MODBUS_UTILS}/modbus_client/modbus_client -m rtu -b $BAUD -p none -s $STOP_BITS $BUS"

# Modbus functions aliases
CMD_READ_COILS=0x01
CMD_READ_DISCRETE_INPUTS=0x02
CMD_READ_HOLDING_REGISTERS=0x03
CMD_READ_INPUT_REGISTERS=0x04
CMD_WRITE_SINGLE_COIL=0x05
CMD_WRITE_SINGLE_REGISTER=0x06
CMD_WRITE_MULTIPLE_COILS=0x0F
CMD_WRITE_MULTIPLE_REGISTER=0x10

# Global scripts variables
DELAY=2

# Echo all to stderr
function log {
	>&2 echo $@
}

# Print sound character
function beep {
	echo -ne '\007'
}

function get_device_model {
	if [ "$#" -ne 1 ]; then
                log "Illegal number of parameters, use: get_device_model SLAVE_ID"
                return 254
        fi
	echo -e $($MBC -a $slave_id -t $CMD_READ_HOLDING_REGISTERS -r 200 -c 6 | grep Data | sed -e 's/.*Data://' -e 's/ 0x00/\\x/g') | tr -d '\0'
}

function get_device_firmware {
	if [ "$#" -ne 1 ]; then
		log "Illegal number of parameters, use: get_device_firmware SLAVE_ID"
		return 254
	fi
	echo -e $($MBC -a $slave_id -t $CMD_READ_HOLDING_REGISTERS -r 250 -c 16 | grep Data | sed -e 's/.*Data://' -e 's/ 0x00/\\x/g') | tr -d '\0'
}

function print_device_info {
	if [ "$#" -ne 1 ]; then
		log "Illegal number of parameters, use: print_device_info SLAVE_ID"
		return 254
	fi
	slave_id=$1
	# Read device model:
	echo -e "Model:   " $(get_device_model $slave_id)
	# Read device firmware version:
	echo -e "Firmware:" $(get_device_firmware $slave_id)
	return 0
}

function ping_device {
	if [ "$#" -ne 1 ]; then
                log "Illegal number of parameters, use: ping_device SLAVE_ID"
		return 254
        fi
	slave_id=$1
	$MBC -a $slave_id -t $CMD_READ_HOLDING_REGISTERS -r 128 > /dev/null 2>&1
	rc=$?
	if [ "$rc" -ne "0" ]
	then
		log "modbus_ping failed, rc: $rc"
		return $rc
	fi
	return 0
}

function check_device {
        if [ "$#" -ne 1 ]; then
                log "Illegal number of parameters, use: check_device SLAVE_ID"
                return 254
        fi
	slave_id=$1
	if ping_device $slave_id
	then
		echo "Device $slave_id found"
	else
		echo "Device $slave_id did not respond"
		exit 1
	fi
	return 0
}

function check_device_model {
        if [ "$#" -ne 2 ]; then
                log "Illegal number of parameters, use: check_device_model SLAVE_ID MODEL"
                return 254
        fi
	slave_id=$1
	expected_model=$2
	real_model=$(get_device_model $slave_id)
	if [ "$real_model" != "$expected_model" ]
	then
		echo "Device $slave_id model did not match, expected: $expected_model, get: $real_model"
		exit 1
	fi
	return 0
}

