-- Read temperature and humidity data from DHT11 sensor.
-- Connect Data pin of DHT11 sesnor to PIN 2 (GPIO 4) of ESP8266 wifi module.
-- Written by K.V.Suresh for 3 Edge on 27/11/2018
-- Ref-esp8266.com - written in LUA

wifi.setmode(wifi.STATION)
        wifi.sta.config("infocus","hariharan")

      tmr.alarm(0, 1000, 1, function(QQ)   
         print("Try Connecting:")
         ip, nm, gw=wifi.sta.getip()
         if ip ~= nil then         
         print("\nIP Info: \nIP Address: ",ip,"\n Netmask: ",nm,"\n Gateway: ",gw)         
         tmr.stop(0)
      end 
end)

       sensorType="dht11" 			-- set sensor type dht11 or dht22
	PIN = 2 --  data pin, GPIO2
	humi=10
        humiold=11
        huminew=12
	temp=20
        tempold=21
        tempnew=22  


	--load DHT module for read sensor
function ReadDHT()
        
	dht=require("dht")
	dht.read(PIN)
	chck=1
	h=dht.getHumidity()
	t=dht.getTemperature()
	if h==nil then h=0 chck=0 end
                  
	if sensorType=="dht11"then
		huminew=h/256
		temp=t/256
	else
		huminew=h/10
		temp=t/10
	end
        
        if huminew==0 then
          humi = humiold
        else
         humi=huminew
         humiold=huminew
        end

        if temp > 40 then
          temp=temp/2
        end
                               
     
        print("Humidity:    "..humi.." %")
	print("Temperature: "..temp.." deg C")
       
	-- release module
	dht=nil
	package.loaded["dht"]=nil   
end     

function sendData()
print('httpget.lua started')

conn = nil
conn = net.createConnection(net.TCP, 0) 

-- show the retrieved web page

conn:on("receive", function(conn, payload) 
                       success = true
                       print(payload) 
                       end) 

-- once connected, request page (send parameters to a php script)
--Sample Querry String http://innovativedesigns.online/Temprature.php?Temp=38&Humidity=58
conn:on("connection", function(conn, payload) 
                       print('\nConnected') 
                       conn:send("GET /temp?"
                        .."Temp="..temp.."&Humidity="..humi                              
                        .." HTTP/1.1\r\n" 
                        .."Host:192.168.43.250\r\n"
					--	.."Port:5000\r\n"						
                        .."Connection: close\r\n"
                        .."Accept: */*\r\n" 
                        .."User-Agent: Mozilla/4.0 "
                        .."(compatible; esp8266 Lua; "
                        .."Windows NT 5.1)\r\n" 
                        .."\r\n")
                       end)

-- when disconnected, let it be known
conn:on("disconnection", function(conn, payload) print('\nDisconnected') end)
                                             
conn:connect(5000,'192.168.43.250')
end

ReadDHT()
sendData()
-- send data every X minute to Innovative Designs

tmr.alarm(2, 30000, 1, function() ReadDHT() sendData() end )