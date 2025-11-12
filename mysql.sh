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

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "installing mysql-server"

systemctl enable mysqld
VALIDATE $? "enabling mysql server" &>>$LOGFILE

systemctl start mysqld
VALIDATE $? "starting mysql" &>>$LOGFILE

# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
# VALIDATE $? "settingup root password"

#below code will seful for idempotent nature
mysql -h db.zarasolutions.shop -uroot -p ${mysql_root_password} -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then
  mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
else
  echo  -e "MYSQL root password is already setup.....$G skipping $N" 
fi 
 
#interviw question
# idempotency?



