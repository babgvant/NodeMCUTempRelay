-- Connect 
ip, nm, gw=wifi.sta.getip()
print("IP address: ",ip)

local httpRequest={}
httpRequest["/"]="index.htm";
httpRequest["/index.htm"]="index.htm";
httpRequest["/style.css"]="style.css";

local getContentType={};
getContentType["/"]="text/html";
getContentType[".htm"]="text/html";
getContentType[".css"]="text/css";
local filePos=0;

if srv then srv:close() srv=nil end
srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(conn,request)
        print("[New Request]");
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
         _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local formDATA = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                print("["..k.."="..v.."]");
                formDATA[k] = v
            end   
        end
        print("path " .. path);
        local cleanpath = string.match(path, "/(.+)");
        if(cleanpath == nil or cleanpath == '') then
            cleanpath = "index.htm";
        end
        print("cleanpath " .. cleanpath);
        if file.open(cleanpath,r) then
            file.close();
            requestFile=cleanpath;
            print("[Sending file "..requestFile.."]");            
            filePos=0;
            local fileExt = string.match(cleanpath, "(%.%w+)");
            if (fileExt == nil or fileExt == '') then
                print("fileExt nil");
                fileExt = '.htm';
            end
            print("fileExt " .. fileExt);
            conn:send("HTTP/1.0 200 OK\r\nContent-Type: "..getContentType[fileExt].."\r\n\r\n");            
        else
            requestFile = ""	
            respText = "{"	
            
			if (cleanpath == "on") then
				gpio.write(switch1_pin, gpio.HIGH)                   
			elseif (cleanpath == "off") then
				gpio.write(switch1_pin, gpio.LOW)
			elseif (cleanpath == "get") then
                dofile("sensordata.lua")
				respText = respText .. "\"temp\": "..temperature..","
				respText = respText .. "\"humidity\": "..humidity..","
				respText = respText .. "\"interval\": "..checkInterval..","
				respText = respText .. "\"switch_state\": "..gpio.read(switch1_pin)..","
				respText = respText .. "\"low\": "..tempLow..","
				respText = respText .. "\"high\": "..tempHigh..""
                print (respText)
			elseif (cleanpath == "set") then
				--print ("set: low "..formDATA["low"].." high "..formDATA["high"])
				if (formDATA) then
					if(formDATA["low"]) then
						tempLow = tonumber(formDATA["low"])
					end
					if(formDATA["high"]) then
						tempHigh = tonumber(formDATA["high"])
					end	
					if(formDATA["interval"]) then
						checkInterval = tonumber(formDATA["interval"])
                        chkTmr:interval(checkInterval * 1000)
					end		
                    dofile("write_poll_settings.lua")		
				end
                --print ("set1: low "..tempLow.." high "..tempHigh)
			else
				print("[File "..path.." not found]");
				conn:send("HTTP/1.0 404 Not Found\r\n\r\n")
				return
			end   
          
            respText = respText .. "}"
							
			conn:send("HTTP/1.0 200 OK\r\nContent-Type: application/json\r\n\r\n");  
        end
    end)
    conn:on("sent",function(conn)
        --print("sent")
        if (requestFile~= nil and requestFile ~= "") then
            if file.open(requestFile,r) then
                file.seek("set",filePos);
                local partial_data=file.read(512);
                file.close();
                if partial_data then
                    filePos=filePos+#partial_data;
                    print("["..filePos.." bytes sent]");
                    conn:send(partial_data);
                    if (string.len(partial_data)==512) then
                        return;
                    end
                   
                end
            else
                print("[Error opening file"..requestFile.."]");
            end
        elseif (respText~= nil and respText ~= "") then
            --print("send response: "..respText)
            conn:send(respText);
        end
        print("[Connection closed]");
        conn:close();
        collectgarbage();
    end)
end)
