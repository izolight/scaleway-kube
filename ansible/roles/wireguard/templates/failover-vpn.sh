#! /bin/bash

# check if vpn works
ping -c 1 {{ VPN_SUBNET }}.1

RESULT=$?

if [ $RESULT -eq 0 ];
then
	exit 0
fi

# get active service
CURRENT=$(cat /tmp/vpn)
DEFAULT=tunnel_0
FALLBACK=tunnel_1

systemctl stop wg-quick@$CURRENT

if [ $CURRENT == $DEFAULT ];
then
	systemctl start wg-quick@$FALLBACK
elif [ $CURRENT == $FALLBACK ];
then
	systemctl start wg-quick@$CURRENT
fi
