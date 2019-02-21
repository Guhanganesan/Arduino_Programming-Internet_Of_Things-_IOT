-- load credentials, 'SSID' and 'PASSWORD' declared and initialize in there

local IDLE_AT_STARTUP_MS = 10000;
tmr.alarm(1,IDLE_AT_STARTUP_MS,0,function()
    print("Delay completed ")
    dofile("flask_temp.lua")--the functional programme
end)