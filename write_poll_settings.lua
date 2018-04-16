file.remove("poll_settings.lua");
file.open("poll_settings.lua","w+");
w = file.writeline
w("tempLow = "..tempLow);
w("tempHigh = "..tempHigh);
w("checkInterval = "..checkInterval);
file.close();
