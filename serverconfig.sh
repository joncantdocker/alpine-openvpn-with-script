#!/bin/bash
echo "Note: A server must be setup before clients can be authorised or deauthorised. Also capitalise commands because coding in lowercase as well is too much effort"
read -p "[S]etup, [A]uthorise a new client, [D]eauthorise an old client, or [V]iew the list of clients? " Path

#if statement to determine setup
if [ $Path = "S" ]
then
	#request servername
	read -p "URL/IP of the new server? " ServerName
	
	#create $OVPN_DATA volume container
	export OVPN_DATA=openvpn_data
	docker volume create --name $OVPN_DATA
	
	#initialise the container
	docker run -v $OVPN_DATA:/etc/openvpn --rm rlesouef/alpine-openvpn initopenvpn -u udp://$ServerName
	docker run -v $OVPN_DATA:/etc/openvpn --rm -it rlesouef/alpine-openvpn initpki

	#start OpenVPN server process
	docker run --name openvpn -v $OVPN_DATA:/etc/openvpn -v /etc/localtime:/etc/localtime:ro -d -p 1194:1194/udp --cap-add=NET_ADMIN rlesouef/alpine-openvpn
	echo "Run the program again to authorise clients "
fi
#if statement to determine viewing
if [ $Path = "V" ]
then
	#view authorised clients
	docker run -v $OVPN_DATA:/etc/openvpn --rm rlesouef/alpine-openvpn listcerts
else
	#nested if statement to determine if authorise new or deauthorise old
	if [ $Path = "D" ]
	then
		#view authorised clients
		docker run -v $OVPN_DATA:/etc/openvpn --rm rlesouef/alpine-openvpn listcerts
		
		#select client to deauthorise
		read -p "Client name to revoke? " ClientName
		
		#deauthorise client
		docker run -v $OVPN_DATA:/etc/openvpn --rm -it rlesouef/alpine-openvpn revokeclient $ClientName
		
		echo "$ClientName is no longer authorised "
	fi
	if [ $Path = "A" ]
	then
		#view authorised clients
		docker run -v $OVPN_DATA:/etc/openvpn --rm rlesouef/alpine-openvpn listcerts
		echo "note the server itself is always authorised"

		#select client to authorise
		read -p "Client name to authorise? e.g. user1 " ClientName

		#generate a client certificate
		docker run -v $OVPN_DATA:/etc/openvpn --rm -it rlesouef/alpine-openvpn easyrsa build-client-full $ClientName

		#save the certificate to a file called ClientName.ovpn
		docker run -v $OVPN_DATA:/etc/openvpn --rm rlesouef/alpine-openvpn getclient $ClientName > $ClientName.ovpn
		
		#user confirmation
		echo "The config settings were saved to the file $ClientName.ovpn "
	fi
fi
