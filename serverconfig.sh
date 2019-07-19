#!/bin/bash
echo "Welcome to the vpn server setup script."
echo "Due to life you can only run this script once before having to remove a docker container."
echo "To remove the docker container run 'docker container ls -a' to see the running container then docker container stop then rm the container marked rlesouef/alpine-openvpn"

read -p "URL/IP of server? " ServerName
export OVPN_DATA=openvpn_data
docker volume create --name $OVPN_DATA
docker run -v $OVPN_DATA:/etc/openvpn --rm joncantdocker/alpine-openvpn-with-script initopenvpn -u udp://$ServerName
docker run -v $OVPN_DATA:/etc/openvpn --rm -it rlesouef/alpine-openvpn initpki
docker run --name openvpn -v $OVPN_DATA:/etc/openvpn -v /etc/localtime:/etc/localtime:ro -d -p 1194:1194/udp --cap-add=NET_ADMIN rlesouef/alpine-openvpn

#view authorised clients
docker run -v $OVPN_DATA:/etc/openvpn --rm rlesouef/alpine-openvpn listcerts

echo "note: the server itself is always authorised"

Continue="yes"

#While Loop for adding muliple clients
while [ "$Continue" != "" ]
do
	#select client to authorise
	read -p "Client name to authorise? (e.g. user1) " ClientName

	#generate a client certificate
	docker run -v $OVPN_DATA:/etc/openvpn --rm -it rlesouef/alpine-openvpn easyrsa build-client-full $ClientName

	#save the certificate to a file called ClientName.ovpn
	docker run -v $OVPN_DATA:/etc/openvpn --rm rlesouef/alpine-openvpn getclient $ClientName > $ClientName.ovpn

	#view authorised clients again
	docker run -v  $OVPN_DATA:/etc/openvpn --rm rlesouef/alpine-openvpn listcerts
	#remove last 2 lines which are bad
	head -n -2 $ClientName.ovpn > temp.ovpn ; mv temp.ovpn $ClientName.ovpn
	#add to the start to have it work
	echo 'push "route-nopull"' | cat - $ClientName.ovpn > temp.ovpn && mv temp.ovpn $ClientName.ovpn
	echo 'push "route 172.20.10.3 255.255.255.0 vpn_gateway"' | cat - $ClientName.ovpn > temp.ovpn && mv temp.ovpn $ClientName.ovpn

	#user confirmation
	echo "The config settings were saved to the file $ClientName.ovpn "
	read -p "Do you want to add another client? (enter nothing to stop adding clients) " Continue
done
