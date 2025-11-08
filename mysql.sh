#!/bin/bash
USERID=$(id -u) 
TIMESTAMP=$(date +%F-%H-%M-%S) # to check time
SCRIPT_NAME=$(echo $0 | cut -d "." -f1) #script name
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log #to save script name with time
R="\e[31m"
G="\e[32m"
N="\e[0m"
VALIDATE(){
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
 echo " please run this script with super user"
 exit 1 
else 
 echo"  you are a super user"
fi

dnf install mysql-server -y &>>$LOGFILE
validate $? "installing mysql-server"

systemctl enable mysqld
validate $? "enabling mysql server" &>>$LOGFILE

systemctl start mysqld
validate $? "starting mysql" &>>$LOGFILE

mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
validate $? "settingup root password"

 