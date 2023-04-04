#!/bin/bash

. setup_modbus.sh

for slave_id in "$@"
do
        check_device $slave_id
        check_device_model $slave_id "WB-LED"
        print_device_info $slave_id

	# Устанавливаем независимый режим работы (W+W+W+W):
	# Записываем в регистр (функция 0x06) с номером 4000 значение 0
	$MBC -a $slave_id -t $CMD_WRITE_SINGLE_REGISTER -r 4000 0

	for channel in 0 1 2 3
	do
		# На короткое нажатие входа X (holding-регистр 100X) вешаем переключение состояния (0x3) выхода X (coil-регистр X)
		$MBC -a $slave_id -t $CMD_WRITE_SINGLE_REGISTER -r "100${channel}" "0x300${channel}"
		# На долгое нажатие входа X (holding-регистр 102X) вешаем увеличение/уменьшение через раз значения (0xB) яркости выхода X (holding-регистр 200X, записан как X, т.к. 2000 из адреса вычли, см. документацию https://wirenboard.com/wiki/WB-LED_Modbus_Registers#Настройка_действий_для_нажатий)
		$MBC -a $slave_id -t $CMD_WRITE_SINGLE_REGISTER -r "102${channel}" "0xB00${channel}"
	done

done
