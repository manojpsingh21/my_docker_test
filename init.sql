GRANT ALL PRIVILEGES ON *.* TO 'presql'@'%d' WITH GRANT OPTION;
ALTER USER 'presql'@'%' IDENTIFIED WITH mysql_native_password BY 'Rupee@123';
FLUSH PRIVILEGES;
