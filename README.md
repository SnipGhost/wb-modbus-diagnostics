# Wirenboard devices modbus diagnostics

## Pre-requirements

Install or build: [wirenboard/modbus-utils](https://github.com/wirenboard/modbus-utils)

Example install old version for amd64 (1.2):
```bash
sudo apt install https://github.com/contactless/modbus-utils/releases/download/1.2/modbus-utils_1.2_amd64.deb
```
OR
```bash
wget https://github.com/contactless/modbus-utils/releases/download/1.2/modbus-utils_1.2_amd64.deb
mkdir modbus-utils
dpkg-deb -R modbus-utils_1.2_amd64.deb modbus-utils
```

Build:
```bash
git clone https://github.com/wirenboard/modbus-utils.git
cd modbus-utils
# Download libmodbus repo
git submodule update

# Build libmodbus
cd libmodbus
sudo apt update
sudo apt install autoconf automake libtool build-essential
./autogen.sh
./configure
make
# Check
ls -l src/.libs/
cd ..

# Build modbus_client & modbus_server
gcc ./modbus_client/modbus_client.c -I./common \
	-I./libmodbus/src/ -L./libmodbus/src/.libs/ -lmodbus \
	-o ./modbus_client/modbus_client
gcc ./modbus_server/modbus_server.c -I./common \
	-I./libmodbus/src/ -L./libmodbus/src/.libs/ -lmodbus \
	-o ./modbus_server/modbus_server
```


## Usage

```bash
./test-wb-led.sh WB_LED_ADDR1 [WB_LED_ADDR2 ...]
./test-wb-mdm3.sh WB_MDM2_ADDR1 [WB_MDM3_ADDR2 ...]
```

## Examples

```
root@metroid:~/wb-modbus-diagnostics # ./test-wb-led.sh 
root@metroid:~/wb-modbus-diagnostics # ./test-wb-led.sh 21
modbus_ping failed, rc: 1
Device 21 did not respond
root@metroid:~/wb-modbus-diagnostics # ./test-wb-led.sh 20
Device 20 found
Device 20 model did not match, expected: WBLED, get: WBMD3
root@metroid:~/wb-modbus-diagnostics # ./test-wb-mdm3.sh 20
Device 20 found
Model:    WBMD3
Firmware: 2.5.3
Enable channel 0 with mininal brightness level
SUCCESS: written 1 elements!
SUCCESS: written 1 elements!
Set channel 0 brightness to 40
SUCCESS: written 1 elements!
Set channel 0 brightness to 43
SUCCESS: written 1 elements!
Set channel 0 brightness to 45
SUCCESS: written 1 elements!
Disable channel 0
SUCCESS: written 1 elements!
Enable channel 1 with mininal brightness level
SUCCESS: written 1 elements!
SUCCESS: written 1 elements!
Set channel 1 brightness to 40
SUCCESS: written 1 elements!
Set channel 1 brightness to 43
SUCCESS: written 1 elements!
Set channel 1 brightness to 45
SUCCESS: written 1 elements!
Disable channel 1
SUCCESS: written 1 elements!
Enable channel 2 with mininal brightness level
SUCCESS: written 1 elements!
SUCCESS: written 1 elements!
Set channel 2 brightness to 40
SUCCESS: written 1 elements!
Set channel 2 brightness to 43
SUCCESS: written 1 elements!
Set channel 2 brightness to 45
SUCCESS: written 1 elements!
Disable channel 2
SUCCESS: written 1 elements!
```
