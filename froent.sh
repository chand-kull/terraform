#!/bin/bash
USERID=$(id -u) 
TIMESTAMP=$(date +%F-%H-%M-%S) # to check time
SCRIPT_NAME=$(echo $0 | cut -d "." -f1) #script name
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log #to save script name with time
R="\e[31m"
G="\e[32m"
N="\e[0m"
echo "please enter DB password:"
read -s mysql_root_password
VALIDATE() {
   if [ $1 -ne 0 ]
   then 
      echo "$2..FAILURE"
      exit 1
   else
    echo "$2 ...SUCCESS"
   fi
}

if [ $USERID  -ne 0 ]
then 
 echo "please run this script with super user"
 exit 1 
else 
 echo "you are a super user"


dnf install nginx -y &>>$LOGFILE
VALIDATE $? "installing nginx"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "enable nginx"

systemctl start nginx  &>>$LOGFILE
VALIDATE $? "start nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "removing nginx"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "downloading code"

cd /usr/share/nginx/html &>>$LOGFILE
VALIDATE $? "extract code"

cp /home/ec2-user/terraform/expense.config /etc/nginx/default.d/expense.conf
VALIDATE $? "copy code"


unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE $? "unzip code"

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "restart nginx"









