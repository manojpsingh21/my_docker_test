CREATE USER 'presql'@'localhost' IDENTIFIED BY 'Rupee@123';
GRANT ALL PRIVILEGES ON *.* TO 'presql'@'%d' WITH GRANT OPTION;
ALTER USER 'presql'@'%' IDENTIFIED WITH mysql_native_password BY 'Rupee@123';
FLUSH PRIVILEGES;
SET GLOBAL max_connections = 6000;
