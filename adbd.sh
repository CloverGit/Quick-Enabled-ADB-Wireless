#!/system/bin/sh
pwd=`pwd` 
help="Options: \n    -i    Install to $bin \n    -s    Enabled ADB Wireless \n    -q    Disabled ADB Wireless \n    -p    Ues costom port \n    -f    Forced to enable(Without busybox)    -h    Displathis help \n    -v    Display version information \n" 
bin="/system/bin"  
echo "Work on $pwd" 
echo -e "\033[36m * Need root \033[0m" 
echo -e "\033[36m * Some features may be that requires busybox support(Does not include -f option) \033[0m" 
#Check root(Unfulfilled) 
#if [ "`busybox id -u`" -ne 0 ] ;then 
#	exit|clear|su -c sh $pwd/$0 $* 
#fi 
#Check root 
if [ "`echo $USER`" != "root" -a "$1" != "-h" -a "$1" != "-f" ] ;then 
		echo "\033[41;33m Error: Switch to root and try again \033[0m"  
		exit  
fi 
b=' ' 
i=0 
while [ $i -le  100 ] 
do 
	printf "%-60s%d%%\r" "$b" "$i" 
	# %-20s    %d    %%   \r 
	sleep 0.01 
	i=`expr 2 + $i` 
	b=#$b 
done 
echo 
#Check USB debugging 
if [ "`settings get global adb_enabled`" -eq 0 ] ;then 
		settings put global adb_enabled 1 
	else 
		echo "USB debugging enabled" 
fi 
#Check network 
if [ "`settings get global wifi_on`" -eq 0 ] ;then 
		echo "Enable wifi..." 
		settings put global wifi_on 1 
	else 
		echo "Wifi enabled" 
fi 
if [ "$#" -eq 0 -o "$1" = "-s" -o "$1" = "-start" ] ;then 
	#Core Start 
	setprop service.adb.tcp.port 5037 
	stop adbd 
	start adbd 
	#Core End 
	echo "Enabled ADB Wireless " 
	echo "Use \"adb connect "`ifconfig wlan0 | grep -o -E "ip [0-9.]+" | sed -e "s/ip //g"`":5037\" to connect" 
	sleep 0.5 
	echo "Type $0 -h for help"
#Force
elif [ "$1" = "-f" ] ;then 
		setprop service.adb.tcp.port 5037 
		stop adbd 
		start adbd 
		echo "Forced to enable\(May be invalid\)" 
		echo "Port 5037"  
#Custom port 
elif [ "$1" = "-p" ] ;then 
		echo "Please enter a custom port" 
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
#Installation 
elif [ "$1" = "-i" ] ;then 
	echo "Installing..." 
	cp $pwd/$0 $path1/adbd 
	chmod 0755 $bin/adbd  
	chown 0:2000 /system/bin/adbd 
	echo "Adbd is now installed in/system/adbd" 
#Quit 
elif [ "$1" = "-q" ] ;then 
		stop adbd 
	echo "ADB Wireless is disabled" 
#Version 
elif [ "$1" = "-v" -o $1 = "-version" ] ;then 
	echo "Enabled ADB Wireless" 
	echo `date` 
	echo "adbd version 1.3" 
	echo "`adb version | sed -e "s/Android Debug Bridge version"/"ADB version"/g`" 
#Help 
elif [ "$1" = "-h" -o $1 = "-help" ] ;then 
	echo "Usage:$0 [OPTIONS]..." 
	echo $help 
else 
	echo "$0: invalid option $1" 
	echo "Usage:$0 [OPTIONS]..." 
	echo "Enabled ADB Wireless" 
	echo $help 
fi
