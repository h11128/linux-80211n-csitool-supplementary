#!/usr/bin/sudo /bin/bash
sudo stop network-manager
sudo modprobe -r iwldvm iwlwifi mac80211
modprobe -r iwlwifi mac80211 cfg80211
modprobe iwlwifi debug=0x40000
if [ "$#" -ne 2 ]; then
    echo "Going to use default settings!"
    chn=64
    bw=HT20
else
    chn=$1
    bw=$2
fi
sudo ifconfig wlan1 2>/dev/null 1>/dev/null
while [ $? -ne 0 ]
do
	sudo ifconfig wlan1 2>/dev/null 1>/dev/null
done
sudo iw dev wlan1 interface add mon0 type monitor

sudo ifconfig wlan1 down
while [ $? -ne 0 ]
do
    sudo ifconfig wlan1 down
done

sudo ifconfig mon0 up
while [ $? -ne 0 ]
do
           sudo ifconfig mon0 up
done

sudo iw mon0 set channel $chn $bw

sudo chmod 777 /sys/kernel/debug/
sudo chmod 777 /sys/kernel/debug/tracing/
sudo echo 0x4101 | sudo tee 'find /sys -name monitor_tx_rate'
