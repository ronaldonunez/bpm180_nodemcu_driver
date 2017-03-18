-- declare local constants
local id = 0
local i2c_sda = 2
local i2c_scl = 1

-- initialize i2c module
i2c.setup(id, i2c_sda, i2c_scl, i2c.SLOW)


-- loads bpm180 driver
local bpm180 = require "bpm180"

calib_array = bpm180.read_calibration_data(id)

for i=bpm180.BPM180_CALIB_DATA_START, bpm180.BPM180_CALIB_DATA_END, 2
do
	print(calib_array[i])	
end
