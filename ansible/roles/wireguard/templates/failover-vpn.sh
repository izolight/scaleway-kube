#! /bin/bash

# check if vpn works
ping -c 1 1.1.1.1

RESULT=$?

if [ $RESULT -eq 0 ];
then
	echo "Everything seems fine"
	exit 0
fi

echo "Ping didn't return, endpoint is probably down"
# get active service
CURRENT=$(cat /tmp/vpn)
DEFAULT=tunnel_0
FALLBACK=tunnel_1

echo "Stopping active vpn"
systemctl stop wg-quick@$CURRENT

if [ $CURRENT == $DEFAULT ];
then
	echo "Failing over to $FALLBACK"
	systemctl start wg-quick@$FALLBACK
elif [ $CURRENT == $FALLBACK ];
then
	echo "Failing over to $DEFAULT"
	systemctl start wg-quick@$DEFAULT
fi
