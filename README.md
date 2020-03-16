Prerequisite to run application:

•	AlphaClient Machines : Servers whose ssh attempts we want to track.
•	AlphaServer Machine : Server to send & display real time ssh attempts of all AlplaClient machines.
•	I used Azure for my testing purpose where my AlphaClient & AplhaServer machines are running.
•	Terraform needed in case you don’t have AlphaServer and want to create new one.
•	Need to create service principal if you want to create server using terraform script.
https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal


Steps to Run application:


1-	Need to download alphaClient.sh & schedule.sh on each AlphaClient VM whose ssh attempts we want to track. Link : https://github.com/SajalGolas/sshmonit.git
2-	Edit schedule.sh scripts and replace the your AlphaServer machine credentials.
3-	Make sure if you’re passing password in script then sshpass module should be available in AlphaServer machine if not then install by using apt-get install -y sshpass.
4-	Run below command
    nohup ./schedule.sh & or ./schedule.sh & (Any to keep the script running in background)
5-	Login into your AlphaServer machine and see the output of  real time ssh attempts(Successful & Failed both) of all AlphaClient machines with proper IP, Date & Time in output.txt file.
     
Command to see ssh report in AlphaServer machine :

tail -f output.txt or simple cat output.txt


Note : I used infinite while loop to keep the script running or you can also schedule 
          AlphaClient.sh script as cron job in AlphaClient machines.


Steps to create server using Terrraform :

1-	Create service principal in Azure. (Follow above doc)

2-	Go inside the alphaServer.tf directory (Make sure replace your ssh key)

3-	Terraform init

4-	Terraform plan

5-	Terrafrom apply.




