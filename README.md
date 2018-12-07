# networkchanger

Usage: networkchanger.sh [ip xxx.xxx.xxx.xxx/xx] [gw xxx.xxx.xxx.xxx] [dns xxx.xxx.xxx.xxx,[xxx.xxx.xxx.xxx]]
Install:
```
git clone https://github.com/frazei/networkchanger.git
sudo cp networkchanger/networkchanger.sh /usr/local/bin
sudo chmod +x /usr/local/bin/networkchanger.sh
```

Example:
```
/usr/local/bin/networkchanger.sh ip 192.168.1.10/24
```

It works with /etc/dhcpcd.conf and /etc/netplan/50-cloud-init.yaml
