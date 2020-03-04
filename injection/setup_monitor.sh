#!/usr/bin/sudo /bin/bash
sudo stop network-manager 
sudo modprobe -r iwldvm iwlwifi mac80211 cfg80211
sudo modprobe iwlwifi connector_log=0x1
if [ "$#" -ne 2 ]; then
    echo "Going to use default settings!"
    chn=64
    bw=HT20
else
    chn=$1
    bw=$2
fi

sudo iwconfig wlan1 mode monitor 2>/dev/null 1>/dev/null
while [ $? -ne 0 ]
do
    sudo iwconfig wlan1 mode monitor 2>/dev/null 1>/dev/null
done

sudo ifconfig wlan1 up 2>/dev/null 1>/dev/null
while [ $? -ne 0 ]
do
  sudo ifconfig wlan1 up 2>/dev/null 1>/dev/null
done

sudo iw wlan1 set channel $chn $bw 



