#!/bin/bash

# Copyright (C) 2018 Francesco Zei <zei@communicationbox.it>

function usage {
	echo -e "Usage: networkchanger.sh [ip xxx.xxx.xxx.xxx/xx] [gw xxx.xxx.xxx.xxx] [dns xxx.xxx.xxx.xxx,[xxx.xxx.xxx.xxx]]"
	exit 1
}

if [ ! $1 ]; then
	usage
fi

POSITIONAL=()
while [[ $# -gt 0 ]]
do

#CHECKING PARAMS VALUES
case $1 in
	ip)
		if [ ! $2 ]; then
			echo "IP non specificato"
			usage
		fi

		newip="$2"
		echo "IP indicato: ${newip}"
		shift # past argument
    		shift # past value
	;;
	gw)
		if [ ! $2 ]; then
                        echo "GW non specificato"
                        usage
                fi

                newgw="$2"
                echo "GW indicato: ${newgw}"
		shift # past argument
    		shift # past value
	;;
	dns)
		if [ ! $2 ]; then
                        echo "DNS non specificato"
                        usage
                fi

                newdns="$2"
                echo "DNS indicato: ${newdns}"
                shift # past argument
                shift # past value
	;;
	test)
		test=1
		shift # past argument
		#non fa nulla ma stampa le variabili
	;;
	*)
		if [[ $1 ]]; then
            		echo "Error: Unknown command: ${1}"
        	fi
        	usage
	;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# Retrieves the NIC information
nic=`ifconfig | awk 'NR==1{print $1}' | tr -d ':'`

#if [ $nic != $1 ]; then
#	echo "Invalid NIC"
#	exit 1
#fi

if [ -f "/etc/dhcpcd.conf" ]; then
	echo "Trovato file dhcpcd.conf"
	currip=$(cat /etc/dhcpcd.conf | grep -e '^static ip_address=' | cut -d= -f2)
	currgw=$(cat /etc/dhcpcd.conf | grep -e '^static routers=' | cut -d= -f2)
	currdns=$(cat /etc/dhcpcd.conf | grep -e '^static domain_name_servers=' | cut -d= -f2)
	echo "Current IP: ${currip}"
	echo "Current Gw: ${currgw}"
	echo "Current DNS: ${currdns}"
	if [ $newip ]; then
		sed -i -e "s@^static ip_address=$currip\b@static ip_address=$newip@g" /etc/dhcpcd.conf
		currip=$(cat /etc/dhcpcd.conf | grep -e '^static ip_address=' | cut -d= -f2)
		echo "Nuovo IP: ${currip}"
	fi
	if [ $newgw ]; then
		sed -i -e "s@^static routers=$currgw\b@static routers=$newgw@g" /etc/dhcpcd.conf
		currgw=$(cat /etc/dhcpcd.conf | grep -e '^static routers=' | cut -d= -f2)
                echo "Nuovo GW: ${currgw}"
        fi
	if [ $newdns ]; then
		sed -i -e "s@^static domain_name_servers=$currdns\b@static domain_name_servers=$newdns@g" /etc/dhcpcd.conf
		currdns=$(cat /etc/dhcpcd.conf | grep -e '^static domain_name_servers=' | cut -d= -f2)
		echo "Nuovo DNS: ${currdns}"
	fi
	systemctl restart networking
	ifconfig $nic down
	sleep 3
	ifconfig $nic up
elif [ -f "/etc/netplan/50-cloud-init.yaml" ]; then
	echo "Trovato file 50-cloud-init.yaml"
	ipdns=$(cat /etc/netplan/50-cloud-init.yaml | grep -e 'addresses:' | cut -d: -f2 | tr -d '[]')
	i=0
	for ip in $ipdns; do
		case "$i" in
			"0") currip=${ip} ;;
			"1") currdns=${ip} ;;
		esac
		((i++))
	done
	currgw=$(cat /etc/netplan/50-cloud-init.yaml | grep -e 'gateway4:' | cut -d: -f2 | tr -d '[]')
	echo "Current IP: ${currip}"
        echo "Current Gw: ${currgw}"
        echo "Current DNS: ${currdns}"

	if [ $test ]; then
		exit 1
	fi

	# Creates a backup
	cp /etc/netplan/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml.bk_`date +%Y%m%d%H%M`

	if [ ! $newip ]; then
	       	newip=$currip
       	fi
	if [ ! $newgw ]; then
		newgw=$currgw
	fi
	if [ ! $newdns ]; then
		newdns=$currdns
	fi
	cat > /etc/netplan/50-cloud-init.yaml <<EOF
# File generato tramite networkchanger.sh
network:
    ethernets:
        ${nic}:
            addresses: [${newip}]
            gateway4: ${newgw}
            nameservers:
                    addresses: [${newdns}]
            dhcp4: no
    version: 2
EOF
	netplan apply
	cat /etc/netplan/50-cloud-init.yaml
fi
