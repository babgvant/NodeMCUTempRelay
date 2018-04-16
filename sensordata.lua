PIN = 4 --  data pin, GPIO2

dht=require("dht")
status,temp,humi,temp_decimial,humi_decimial = dht.read(PIN)
--print("status: "..status.." temp: "..temp.." humi: "..humi.." temp_decimial: "..temp_decimial.." humi_decimial: "..humi_decimial)
if( status == dht.OK ) then   
    dht_error = nil         
	-- Prevent "0.-2 deg C" or "-2.-6"          
	temperature = temp--remove on float build.."."..(math.abs(temp_decimial)/100)
	humidity = humi--remove on float build.."."..(math.abs(humi_decimial)/100)
	-- If temp is zero and temp_decimal is negative, then add "-" to the temperature string
	if(temp == 0 and temp_decimial<0) then
		temperature = "-"..temperature
	end
    
	 print("temperature: "..temperature.." humidity: "..humidity)
elseif( status == dht.ERROR_CHECKSUM ) then          
	dht_error = "DHT Checksum error"
	temperature=-9991 --TEST
elseif( status == dht.ERROR_TIMEOUT ) then
	dht_error ="DHT Time out"
	temperature=-9992 --TEST
else
    dht_error ="DHT Error"
    temperature=-9993 --TEST
end

-- Release module
dht=nil
package.loaded["dht"]=nil
