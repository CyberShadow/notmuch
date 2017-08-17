#!/bin/bash

# Reverse shell from Travis for debugging heisenbugs

# On your development machine, run this:
# stty -icanon -isig -echo && nc -vklp 8888

# Remember to kill the job through the web UI when you're done debugging!

# Make bash prompts reasonable by removing the humongous container hostname

export PS1='\w\$ '

# Keep Travis from killing the job due to log inactivity
while true
do
	echo 'Still alive!'
	sleep 10
done &

# Connect loop
while true
do
	echo 'Connecting... '
	# OSX
	# script /dev/null /bin/bash -i >& /dev/tcp/89.28.117.31/8888 0>&1
	# Linux
	script /dev/null >& /dev/tcp/89.28.117.31/8888 0>&1
	echo 'Connection terminated'
	sleep 1
done
