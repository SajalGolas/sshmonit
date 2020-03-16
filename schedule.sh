#!/bin/bash

while true; do
 ./alphaClient.sh | sshpass -p admin@12345678 ssh sshadmin@52.163.115.169 "cat > output.txt" #IP,Username & Password for AlphaServer where you want to send AlphaClient ssh attempt reports
 sleep 1 #that would mean running the actual script every 1 sec
done

#You can also pass the ssh key or type password at run time. 
#You can also schedule this script in cron job.