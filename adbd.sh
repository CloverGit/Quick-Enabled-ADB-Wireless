#!/system/bin
b=' '
i=0
while [ $i -le  100 ]
do
        printf "%-60s%d%%\r" "$b" "$i"
        #Options can be decomposed into %-20s    %d    %%   \r
        sleep 0.01
        i=`expr 2 + $i`
        b=#$b
done
echo
if [ "$#" -eq 0 -o "$1" = "-s" -o "$1" = "-start" ] ;then
        #Core Start
        setprop service.adb.tcp.port 5555 
        stop adbd 
        start adbd 
        echo "Enabled ADB Wireless "
        echo "Use \"adb connect "`ifconfig wlan0 | grep -o -E "ip [0-9.]+" | sed -e "s/ip //g"`":5555\" to connect"
        #Core End
        sleep 0.5
        echo "Type $0 -h for help"
elif [ "$1" = "-c" ] ;then
        echo "Please enter a custom ports"
                read keypress
        if [ $keypress -ge 1024 -a $keypress -le 65000 ] ;then
                setprop service.adb.tcp.port $keypress
                stop adbd 
                start adbd 
                echo "Ues costom ports:$keypress"
                echo "Enabled ADB Wireless "
                echo "Use \"adb connect "`ifconfig wlan0 | grep -o -E "ip [0-9.]+" | sed -e "s/ip //g"`":$keypress\" to connect"
        else 
                echo "Please enter a value greater than  or equal to 1042 less than or equal to 65000"
                stop adbd 
                exit
        fi
elif [ "$1" = "-q" ] ;then
                stop adbd
                echo "ADB Wireless is disabled"
elif [ "$1" = "-h" -o $1 = "-help" ] ;then
        echo "Usage:$0 [OPTIONS]..."
        echo "Options: \n    -s    Enabled ADB Wireless \n    -q    Disabled ADB Wireless \n    -c    Ues costom ports \n    -h    Display this help \n    -v    Display version information \n"
elif [ "$1" = "-v" -o $1 = "-version" ] ;then
        echo `date`
        echo "adbd version 1.0"
        echo "`adb version | sed -e "s/Android Debug Bridge version"/"ADB version"/g`"
else
        echo "$0: invalid option $1"
        echo "Usage:$0 [OPTIONS]..."
        echo "Options: \n    -s    Enabled ADB Wireless \n    -q    Disabled ADB Wireless \n    -c    Ues costom ports \n    -h    Display this help \n    -v    Display version information \n"
fi
