#!/bin/bash

# $1 : username 
# $2 : password

username=`echo $1`
password=`echo $2`

touch /etc/postfix/sasl_passwd
echo "[smtp.gmail.com]:587  $username:$password" >>  /etc/postfix/sasl_passwd

sudo chown postfix sasl_password*

exit 0
