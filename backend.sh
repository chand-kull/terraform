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
fi
dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "disabling nodejs"


dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "enabling nodejs"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "installing nodejs"

id expense 
if [ $? -ne 0 ]
then
 useradd expense
 VALIDATE $? "creating expense user"
else
 echo  -e "Expense user alresdy created .....$Y SKIPPING $N"

fi

mkdir  -p /app &>>$LOGFILE
VALIDATE $? "creating app directory"


curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "downloading backend code"


cd /app &>>$LOGFILE
rm -rf /app/*
unzip /tmp/backend.zip
VALIDATE $? "extracting backend code"

npm install &>>$LOGFILE
VALIDATE $? "installing nodejs dependencies"

sudo cp /home/ec2-user/PRACTICE/expense-shell/backend.service  /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "copying backend service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "daemon-reload"

systemctl start backend &>>$LOGFILE
VALIDATE $? "start backend"

systemctl enable backend &>>$LOGFILE
VALIDATE $? "enabling backend"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "installing mysql"

mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "schema loading"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "restart backend"






