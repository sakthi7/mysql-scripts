#Download the script

#Load the script into MySQL database
mysql -u<username> -p mysql < check_user_grants.sql

#Call the script using
call report_user_object_privs('<username>','<hostname>');


