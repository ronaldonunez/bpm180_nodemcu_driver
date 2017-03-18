bpm180 = {}

BPM180_ADDRRESS = 0x77

BPM180_ID_REGISTER = 0xD0
BPM180_SOFT_RESET = 0xE0
BPM180_CTRL_MEAS = 0xf4
BPM180_OUT_MSB = 0xf6
BPM180_OUT_LSB = 0xf7
BPM180_OUT_XLSB = 0xf8

bpm180.BPM180_CALIB_DATA_START = 0xAA
bpm180.BPM180_CALIB_DATA_END = 0xBF

local function bpm180_write_byte(id, register, value)

	i2c.start(id)
	i2c.address(id, BPM180_ADDRRESS, i2c.TRANSMITTER)
	i2c.write(id, register)
	i2c.write(id, value)
	i2c.stop(id)

end

local function bpm180_read_byte(id, register)

	i2c.start(id)
	i2c.address(id, BPM180_ADDRRESS, i2c.TRANSMITTER)
	i2c.write(id, register)
	i2c.stop(id)

	i2c.start(id)
	i2c.address(id, BPM180_ADDRRESS, i2c.RECEIVER)
	local read_value = i2c.read(id, 1)
	i2c.stop(id)

	return read_value:byte(1)
end

local function bpm180_read_word(id, register)
	MSB = bpm180_read_byte(id, register)
	LSB = bpm180_read_byte(id, register+1)

	return MSB*256 + LSB
end

function bpm180.read_calibration_data(id)

	calib_data_array = {}

	for reg=bpm180.BPM180_CALIB_DATA_START, bpm180.BPM180_CALIB_DATA_END, 2
	do
		calib_data_array[reg] = bpm180_read_word(id, reg)
		
		if (reg < 0xB0) or (reg > 0xB4) then
			if calib_data_array[reg] > 32767 then
				calib_data_array[reg] = calib_data_array[reg] - 65536
			end
		end
	end

	return calib_data_array
end

function bpm180.start_measurement(id)

	bpm180_write_byte(id, BPM180_CTRL_MEAS, 0x2e)

end

function bpm180.read_temp_celcius(id)

	return bpm180_read_word(id, BPM180_OUT_MSB)

end

function bpm180.read_temp_celcius_calib(id)

	temperature = bpm180.read_temp_celcius(id)
	calib_array = bpm180.read_calibration_data(id)

	AC5 = calib_array[0xB2]
	AC6 = calib_array[0xB4]
	MC = calib_array[0xBC]
	MD = calib_array[0xBE]

	x1 = (temperature - AC6)*AC5/32768
	x2 = (MC*2048)/(x1 + MD)
	true_temp = (x1 + x2 + 8)/16

	return true_temp/10

end

return bpm180