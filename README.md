<h1>networkchanger</h1>

<h2>Usage:</h2>
<pre>
networkchanger.sh [ip xxx.xxx.xxx.xxx/xx] [gw xxx.xxx.xxx.xxx] [dns xxx.xxx.xxx.xxx,[xxx.xxx.xxx.xxx]]  
</pre>
<h2>Install:</h2>
<pre>
git clone https://github.com/frazei/networkchanger.git
sudo cp networkchanger/networkchanger.sh /usr/local/bin
sudo chmod +x /usr/local/bin/networkchanger.sh
</pre>
<h2>Example:</h2>
<pre>
/usr/local/bin/networkchanger.sh ip 192.168.1.10/24
</pre>
It works with <strong>/etc/dhcpcd.conf</strong> and <strong>/etc/netplan/50-cloud-init.yaml</strong>
