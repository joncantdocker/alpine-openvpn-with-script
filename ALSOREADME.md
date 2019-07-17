Hey this is Jon. I would like to claim that none of the alpine/openvpn dockerfile and stuff is mine. There is a link to the github later.

I made a script so that the server can be configured from a nice little user interface.
You don't have to use it and can use the instructions from https://github.com/rlesouef/alpine-openvpn instead.
They also created the code that I built upon.

To use the script:
1. Download the docker project.
2. Don't run the docker project instead run my script and type 'S' for setup.
2.b Alternatively you can manually setup the openvpn stuff.
3. Run my script again and type 'A' to add users. You may have to run my script several times to add all the users that you want.

The script creates CLIENTNAME.ovpn files for each client that you add in the location that you run it in that can be ran with openvpn or other relevent vpns.
