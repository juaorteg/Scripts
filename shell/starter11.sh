#!/bin/sh

# Alias
alias echo='echo -e'

# Colors
BOLDGREEN='\e[1;32m'
BOLDRED='\e[1;31m'
BOLDBLUE='\e[1;34m'
CYAN='\e[0;34m'
BOLDCYAN='\e[1;36m'
ORANGE='\e[0;33m'
BOLDORANGE='\e[1;33m'
NOCOLOR='\e[0m'

# Need an Interface
[ -z "$1" ] && echo "${BOLDBLUE}Usage: ${BOLDORANGE}${0##*/} ${BOLDRED}<Interface>${NOCOLOR}" &&
  echo "${BOLDBLUE}Usage: ${BOLDORANGE}${0##*/} ${BOLDRED}stop" && exit 1

if [ "$1" != 'stop' ];then
###########################################################################

# Configure your Interface and IP address

INTERNET="$1"	# Internet-connected interface
echo "${BOLDGREEN}Interface : ${BOLDRED}$INTERNET${NOCOLOR}"

# Get IP address
IPADDR=$(/sbin/ifconfig $1|grep 'inet addr'|awk -F: '{print $2}'|awk '{print $1}')

if [ -z $IPADDR ];then echo "${BOLDRED}No IP Address, No Internet?${NOCOLOR}";exit 1;else
echo "${BOLDGREEN}IP Address: ${BOLDRED}$IPADDR${NOCOLOR}";fi

# Do you want the firewall to use NAT?
# If your getting errors, leave it as NO

USE_NAT='NO'

echo "${BOLDBLUE}* $USE_NAT NAT"

# Do you want to LOG bad packets?

USE_LOGS='NO'

echo "* $USE_LOGS LOGS${NOCOLOR}"

# What ports do you want open?
# Separate using spaces, and use colon ':' for ranges for example
#
#  OPEN_TCP_PORTS='21 22 60:80 45'
#
# Will open ports 21, 22, 45, and ports 60-80

OPEN_TCP_PORTS=''
OPEN_UDP_PORTS=''

[ $OPEN_TCP_PORTS ] && [ $OPEN_UDP_PORTS ] &&
  echo "${BOLDORANGE}* Local Open Ports:\n${ORANGE}  [TCP] $OPEN_TCP_PORTS\n  [UDP] $OPEN_UDP_PORTS${NOCOLOR}"

# For added security you MUST specify which ports on a remote server you
# are going to use. If you are planing to surf the internet open port 80,
# if your going to SSH somewhere open port 22, got it?
# (Use the same settings as above for multiple or range ports)

REMOTE_TCP_PORTS='22 80 443'
REMOTE_UDP_PORTS=''

# Optional

# This is if you are planning on using Nmap or Samba
# Every connection you make comes back
# WARNING! This is vulnerable to rootkits
ALLOW_ALL_OUTGOING_PORTS='YES'

if [ $ALLOW_ALL_OUTGOING_PORTS == 'YES' ];then echo "${BOLDORANGE}* Allow all outgoing ports.${NOCOLOR}"
else echo "${BOLDORANGE}* Remote Open ports\n${ORANGE}  [TCP] $REMOTE_TCP_PORTS\n  [UDP] $REMOTE_UDP_PORTS${NOCOLOR}";fi

# Debug
DEBUG='NO'

[ $DEBUG == 'YES' ] && echo "${BOLDORANGE}* Debuging is on"

###########################################################################

# Default Settings

LOOPBACK_INTERFACE="lo"			# homever your system names it
LOOPBACK="127.0.0.1/8"			# reserved loopback address range
CLASS_A="10.0.0.0/8"			# class A private networks
CLASS_B="172.16.0.0/12"			# class B private networks
CLASS_C="192.168.0.0/16"		# class C private networks
CLASS_D_MULTICAST="224.0.0.0/4"		# class D multicast addresses
CLASS_E_RESERVED="240.0.0.0/5"		# class E reserved addresses
BROADCAST_SRC="0.0.0.0"			# broadcast source address
BROADCAST_DEST="255.255.255.255"	# broadcast destination address
PRIVPORTS="0:1023"			# well-known, privileged port range
UNPRIVPORTS="1024:65535"		# unprivileged port range
fi;

# Location of iptables
if [ -f /sbin/iptables ];then IPT="/sbin/iptables"
else if [ -f /usr/sbin/iptables ];then IPT="/usr/sbin/iptables";
else echo "${BOLDRED}No IPTables found...${NOCOLOR}";exit 1;fi;fi
############################################################################

####################
##### Firewall #####
####################

# Kernel Protection

# Enable broadcast echo Protection
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
# Disable Source Routed Packets
for f in /proc/sys/net/ipv4/conf/*/accept_source_route;do echo 0 > $f;done
# Enable TCP SYN Cookie Protection
echo 1 > /proc/sys/net/ipv4/tcp_syncookies
# Disable ICMP Redirect Acceptance
for f in /proc/sys/net/ipv4/conf/*/accept_redirects;do echo 0 > $f;done
# Don't send Redirect Messages
for f in /proc/sys/net/ipv4/conf/*/send_redirects;do echo 0 > $f;done
# Drop Spoofed Packets comming in on an interface, which if replied to,
# would result in the reply going out a different interface.
for f in /proc/sys/net/ipv4/conf/*/rp_filter;do echo 1 > $f;done
# Log packets with impossible addresses
for f in /proc/sys/net/ipv4/conf/*/log_martians;do echo 1 > $f;done

# Removes Existing Rules

echo -n "${BOLDCYAN}Flushing ${CYAN}"
# Remove any existing rules from all chains
$IPT --flush
$IPT -t nat --flush
$IPT -t mangle --flush

echo -n ". "
# Remove user-defined chains
$IPT -X
$IPT -t nat -X
$IPT -t mangle -X

echo -n ". "
# Reset the default policy
$IPT --policy INPUT ACCEPT
$IPT --policy OUTPUT ACCEPT
$IPT --policy FORWARD ACCEPT

echo -n ". "
$IPT -t nat --policy PREROUTING ACCEPT
$IPT -t nat --policy OUTPUT ACCEPT
$IPT -t nat --policy POSTROUTING ACCEPT
$IPT -t mangle --policy PREROUTING ACCEPT
$IPT -t mangle --policy OUTPUT ACCEPT
echo "${BOLDRED}Done.${NOCOLOR}"

# Stop the firewall
if [ "$1" = "stop" ];then
echo "${BOLDRED}Firewall completely stopped! WARNING: THIS HOST HAS NO FIREWALL RUNNING.${NOCOLOR}"
exit 0;fi

echo -n "${BOLDCYAN}Loading Rules ${CYAN}"

# Unlimited traffic on the loopback interface
$IPT -A INPUT -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT

# Set the default policy
$IPT --policy INPUT DROP
$IPT --policy OUTPUT DROP
$IPT --policy FORWARD DROP

# ICMP Policy
$IPT -A INPUT -p icmp -j ACCEPT
$IPT -A OUTPUT -p icmp -j ACCEPT

if [ $USE_NAT = 'YES' ];then
$IPT -t nat --policy PREROUTING DROP
fi

# I have no idea what mangle does, but just leave it commented

#$IPT -t mangle --policy PREROUTING DROP
#$IPT -t mangle --policy OUTPUT ACCEPT

echo -n ". "
# Stop Some Nmap Probes

# All of the bits are cleared
$IPT -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
# SYN and FIN are both set
$IPT -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
# SYN and RST are both set
$IPT -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
# FIN and RST are both set
$IPT -A INPUT -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
# FIN is the only bit set, without the expected accompanying ACK
$IPT -A INPUT -p tcp --tcp-flags ACK,FIN FIN -j DROP
# PSH is the only bit set, without the expected accompanying ACK
$IPT -A INPUT -p tcp --tcp-flags ACK,PSH PSH -j DROP
# URG is the only bit set, without the expected accompanying ACK
$IPT -A INPUT -p tcp --tcp-flags ACK,URG URG -j DROP

# Logs
if [ $USE_LOGS = 'YES' ];then
$IPT -A INPUT -m state --state INVALID -j LOG \
            --log-prefix "INVALID input: "
$IPT -A OUTPUT -m state --state INVALID -j LOG \
            --log-prefix "INVALID output: "
$IPT -A INPUT -i $INTERNET -s $BROADCAST_DEST -j LOG
$IPT -A INPUT -i $INTERNET -d $BROADCAST_SRC -j LOG
fi

if [ $DEBUG = 'YES' ];then
$IPT -A INPUT -m state --state NEW,ESTABLISHED,RELATED -j LOG
$IPT -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j LOG
fi

echo -n ". "

# Nameserver
$IPT -A OUTPUT -p udp --dport 53 -j ACCEPT
$IPT -A INPUT -p udp --sport 53 -j ACCEPT

# Refuse spoofed packets pretending to be from
# the external interface's IP address
$IPT -A INPUT -i $INTERNET -s $IPADDR -j DROP

# Refuse Invalid packets
$IPT -A INPUT -m state --state INVALID -j DROP
$IPT -A OUTPUT -m state --state INVALID -j DROP

# Refuse packets claiming to be from Class A private network
$IPT -A INPUT -i $INTERNET -s $CLASS_A -j DROP

# Refuse packets claiming to be from a Class B private network
$IPT -A INPUT -i $INTERNET -s $CLASS_B -j DROP

# Refuse packets claiming to be from a Class C private network
$IPT -A INPUT -i $INTERNET -s $CLASS_C -j DROP

# Refuse packets claiming to be from the loopback interface
$IPT -A INPUT -i $INTERNET -s $LOOPBACK -j DROP

# Refuse malformed broadcast packets
$IPT -A INPUT -i $INTERNET -s $BROADCAST_DEST -j DROP

$IPT -A INPUT -i $INTERNET -d $BROADCAST_SRC -j DROP

# Refuse limited broadcasts
$IPT -A INPUT -i $INTERNET -d $BROADCAST_DEST -j DROP

# Refuse Class D multicast addresses
# illegal as a source address
$IPT -A INPUT -i $INTERNET -s $CLASS_D_MULTICAST -j DROP

# Refuse multicast packets carrying a non-UDP protocol
$IPT -A INPUT -i $INTERNET -p ! udp -d $CLASS_D_MULTICAST -j DROP 2>/dev/null

# Allows incoming multicast packets for the sake of completeness
$IPT -A INPUT -i $INTERNET -p udp -d $CLASS_D_MULTICAST -j ACCEPT

# Refuse Class E reserved IP addresses
$IPT -A INPUT -i $INTERNET -s $CLASS_E_RESERVED -j DROP

# Refuse addresses defined as reserved by the IANA
# 0.*.*.*		- Can't be blocked unilaterally with DHCP
# 169.254.0.0/16 	- Link Local Networks
# 192.0.2.0/24		- TEST-NET

$IPT -A INPUT -i $INTERNET -s 0.0.0.0/8 -j DROP
$IPT -A INPUT -i $INTERNET -s 169.254.0.0/16 -j DROP
$IPT -A INPUT -i $INTERNET -s 192.0.2.0/24 -j DROP

# Allow All Outgoing Ports
if [ $ALLOW_ALL_OUTGOING_PORTS = 'YES' ];then
$IPT -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
# Samba
$IPT -A INPUT -s $IPADDR/24 -p udp -m state --state NEW -j ACCEPT
fi
# Defaults Don't touch
${OPEN_TCP_PORTS:=0} 2> /dev/null
if [ $OPEN_TCP_PORTS = 0 ] 2> /dev/null;then OPEN_TCP_PORT=0;fi
${OPEN_UDP_PORTS:=0} 2> /dev/null
if [ $OPEN_UDP_PORTS = 0 ] 2> /dev/null;then OPEN_UDP_PORT=0;fi
${REMOTE_TCP_PORTS:=0} 2> /dev/null
if [ $REMOTE_TCP_PORT = 0 ] 2>/dev/null;then REMOTE_TCP_PORT=0;fi
${REMOTE_UDP_PORTS:=0} 2> /dev/null
if [ $REMOTE_UDP_PORTS = 0 ] 2> /dev/null;then REMOTE_UDP_PORT=0;fi

echo -n ". "
########################################################################
# Open Local Connections

# Accept Local Services - TCP connections
if [ -x $OPEN_TCP_PORT ];then
for ports in $OPEN_TCP_PORTS;do
$IPT -A INPUT -i $INTERNET -p tcp \
  --sport $UNPRIVPORTS -d $IPADDR \
  --dport $ports -j ACCEPT

$IPT -A OUTPUT -o $INTERNET -p tcp ! --syn \
  -s $IPADDR --sport $ports \
  --dport $UNPRIVPORTS -j ACCEPT
done;fi

# Accept Local Services - UDP Ports
if [ -x $OPEN_UDP_PORT ];then
for ports in $OPEN_UDP_PORTS;do
$IPT -A INPUT -i $INTERNET -p udp \
  --sport $UNPRIVPORTS -d $IPADDR \
  --dport $ports -j ACCEPT

$IPT -A OUTPUT -o $INTERNET -p udp \
  -s $IPADDR --sport $ports \
  --dport $UNPRIVPORTS -j ACCEPT
done;fi

# Accept Remote Connections - TCP Ports
if [ -x $REMOTE_TCP_PORT ];then
for ports in $REMOTE_TCP_PORTS;do
$IPT -A OUTPUT -o $INTERNET -p tcp \
  -s $IPADDR --sport $UNPRIVPORTS \
  --dport $ports -j ACCEPT

$IPT -A INPUT -i $INTERNET -p tcp ! --syn \
  --sport $ports -d $IPADDR \
  --dport $UNPRIVPORTS -j ACCEPT
done;fi

# Accept Remote Connections - UDP Ports
if [ -x $REMOTE_UDP_PORT ];then
for ports in $REMOTE_UDP_PORTS;do
$IPT -A OUTPUT -o $INTERNET -p udp \
  -s $IPADDR --sport $UNPRIVPORTS \
  --dport $ports -j ACCEPT

$IPT -A INPUT -i $INTERNET -p udp \
  --sport $ports -d $IPADDR \
  --dport $UNPRIVPORTS -j ACCEPT
done;fi

########################################################################
echo "${BOLDRED}Done.${NOCOLOR}"
