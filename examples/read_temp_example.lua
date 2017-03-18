-- declare local constants
local id = 0
local i2c_sda = 2
local i2c_scl = 1

-- initialize i2c module
i2c.setup(id, i2c_sda, i2c_scl, i2c.SLOW)


-- loads bpm180 driver
local bpm180 = require "bpm180"

bpm180.start_measurement(id)
tmr.delay(10000)
temperature = bpm180.read_temp_celcius(id)

--prints the uncalibrated temperature
print(temperature)

-- prints the true temperature
print(bpm180.read_temp_celcius_calib(id))