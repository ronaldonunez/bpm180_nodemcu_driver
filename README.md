# BPM180 - Pressure and temperature sensor driver for NodeMCU

The BPM180 is a very common sensor to measure pressure and temperature, it largely distributed in chinese breakout boards as GY-87.
This project implements a Lua module to run on NodeMCU v1.0 (commonly known as v2) using NodeMCU/Lua firmware.

## Requirements

Hardware:
- NodeMCU v1.0 (v2)
- GY-87 or BPM180 equivalent breakout board

Software (Device):
- NodeMCU firmware > 0.9.6 (float version) with i2c moduleat least

Software (Host):
- luatool (or equivalent app to flash the module and examples into the board)

## How to use it

### Setup
To use the module is a three step process:
1. Load bpm180.lua script into ESP8266 module
```bash
$ luatool.py --port /dev/ttyUSB0 --src bpm180.lua --dest bpm180.lua --verbose
```

2. Setup i2c
```lua
-- declare local constants
local id = 0
local i2c_sda = 2
local i2c_scl = 1

-- initialize i2c module
i2c.setup(id, i2c_sda, i2c_scl, i2c.SLOW)
```

3. Load bpm180 module:
```lua
-- loads bpm180 driver
local bpm180 = require "bpm180"
```

### API
- bpm180.start_measurement(id): tells the sensor to read the temperature and the pressure.
- bpm180.read_temp_celcius(id): Returns the raw temperature (without calibration)
- bpm180.read_temp_celcius_calib(id): Returns a more precise temperature (uses calibration parameters to achieve more accurate result)

> Parameter id is the number tied to i2c setup.
