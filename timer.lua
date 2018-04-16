switch1_pin = 1
gpio.mode(switch1_pin, gpio.OUTPUT)

print("start temp timer")

dofile("poll_settings.lua")

if chkTmr then chkTmr:unregister() chkTmr=nil end
chkTmr = tmr.create()
chkTmr:register(checkInterval*1000, tmr.ALARM_AUTO, function(t)
	dofile("sensordata.lua")
    if(dht_error ~= nil) then
        print ("DHT error: "..dht_error)
    else
        local pinVal = gpio.read(switch1_pin)
        local fTemp = tonumber(temperature)
        
        print ("pin: "..pinVal.." temp: "..temperature)
        if(fTemp >= tempHigh) then
            if(pinVal == gpio.LOW) then
                print("enable relay")
                gpio.write(switch1_pin, gpio.HIGH)
            end
        end
        if(fTemp <= tempLow) then
            if(pinVal == gpio.HIGH) then
                print("disable relay")
                gpio.write(switch1_pin, gpio.LOW)
            end
        end
    end
end) 

if not chkTmr then
    print("failed to create timer")
else
    chkTmr:start()
end
