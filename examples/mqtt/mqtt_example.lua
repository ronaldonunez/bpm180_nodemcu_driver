-- Netowrk and MQTT service credentials and parameters
dofile("configs.lua")

-- configure led to show mqtt connection status
mqtt_status_led = 0
gpio.mode(mqtt_status_led, gpio.OUTPUT)
gpio.write(mqtt_status_led, gpio.HIGH)

-- configure i2c
i2c.setup(i2c_conf.id, i2c_conf.sda, i2c_conf.scl, i2c.SLOW)

-- load bpm180 module
local bpm180 = require "bpm180"

-- wifi setup
wifi.setmode(wifi.STATION)
wifi.sta.config(network.ssid, network.passwd)

-- mqtt setup
mqtt_service = mqtt.Client("clientid", 120, mqtt_setup.user, mqtt_setup.passwd)

mqtt_service:on("connect",
	function(client)
		print("INFO: Connected to broker")
		gpio.write(mqtt_status_led, gpio.LOW)

		bpm180.start_measurement(i2c_conf.id)
		tmr.delay(10000) -- 10ms
		temperature = bpm180.read_temp_celcius_calib(i2c_conf.id)

		mqtt_service:publish(MQTT_TOPIC, tostring(temperature), 0, 0)
		mqtt_service:close()
	end)

mqtt_service:on("offline", 
	function(client) 
		print("INFO: Disconnected from broker")
	end)

tmr.create():alarm(PUBLISH_INTERVAL*60*1000, tmr.ALARM_AUTO, 
	function() 
		mqtt_service:connect(mqtt_setup.broker_url, mqtt_setup.port)
	end)

