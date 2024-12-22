#!/bin/bash

EXPECTED_PARAMS=2

if [ $# -ne $EXPECTED_PARAMS ]; then
  echo "Error: You need to provide exactly $EXPECTED_PARAMS parameters."
  echo "Usage: $0 <build_tar_file> <initialization_type>"
  exit 1
fi


build_version=$1
initialization_type=$2


echo Deploying build version ..... $build_version
echo initialization_type     ..... $initialization_type

sleep 2

if [ "$initialization_type" = "DB" ]; then
  echo "As initialization_type is DB initializing only for taking dump."
  flag=1
else
    if [ "$initialization_type" = "A" ]; then
     echo "As initialization_type is A assuming we have already stored data in DB"
    else
     echo "Please pass correct initialization_type value"
    fi
fi

tar -xvf $build_version

if [ $? -eq 0 ]; then
    echo "Tar file opened successfully..."
else
    echo "Cannot able to open tar file ...exiting shellcript process..."
fi

mkdir configs entrypoints my_redis_data mysql_files miscs
mkdir -p ./my_linux_master/Application/Exec/
mkdir -p ./my_linux_slave/Application/Exec/
mkdir -p ./webservice_master/WSLogs40/
mkdir -p ./webservice_slave/WSLogs40/
cp -r ./WEB/RupeeSeedWS/ ./webservice_master/
cp -r ./WEB/RupeeSeedWS/ ./webservice_slave/
cp -r ./OMS/* ./my_linux_master/Application/Exec/
cp -r ./OMS/* ./my_linux_slave/Application/Exec/
rm -rf WEB/ INCRRMS/ Configure.sh RMS/ OMS/ READ-ME


git clone https://github.com/manojpsingh21/my_docker_test.git



cp ./my_docker_test/AutoStartSystem.sh ./my_docker_test/master_oms/.bashrc ./my_docker_test/master_oms/.License.ini ./my_docker_test/master_oms/rupeeseed.env  ./my_docker_test/master_oms/entrypoint_master.sh ./my_linux_master/
cp ./my_docker_test/AutoStartSystem.sh ./my_docker_test/slave_oms/.bashrc ./my_docker_test/slave_oms/.License.ini ./my_docker_test/slave_oms/rupeeseed.env   ./my_docker_test/slave_oms/entrypoint_master.sh ./my_linux_slave/

cp ./my_docker_test/init.sql ./my_docker_test/my.cnf ./my_docker_test/sshd_config ./configs/
mv ./my_docker_test/docker-compose.yaml ./
cp  ./my_docker_test/libmysqlclient.so.18  ./my_linux_master/
cp  ./my_docker_test/libmysqlclient.so.18  ./my_linux_slave/
mv ./my_docker_test/slave_oms/StartSystem.sh ./my_linux_slave/Application/Exec/ShellScripts/StartSystem.sh
mv ./my_docker_test/WebAdaptor ./my_linux_slave/Application/Exec/Run/
mv ./my_docker_test/sysctl.conf ./configs/
mv ./dump.rdb ./my_redis_data/
rm ./my_docker_test/libmysqlclient.so.18



if [ "$flag" -eq 1 ]; then
    echo "Flag is 1, performing the action..."
    docker compose up my_db -d
    echo "Action performed.DB is UP..Please import the backup.."
else
    echo "Flag is not 1, no action taken."
    docker compose up -d
fi
