echo "Container $1  and Operation = $2"


case $1 in
    WSM)
        echo "Starting the Webservice Master (WSM) ...."
        container_name=$(docker ps -a | grep "webservice_master"  | awk '{print $NF}')
        echo "Starting the container $container_name"
        if [ "$2" == "1" ]; then
        docker start $container_name
        echo "Started the container $container_name"
        elif [ "$2" == "0" ]; then
        docker stop $container_name
        echo "Stopped the container $container_name"
        else
        echo "Invalid command option"
        fi
        ;;
    WSS)
        echo "Starting the Webservice Slave (WSS) ..."
        container_name=$(docker ps -a | grep "webserviceSlaveOne"  | awk '{print $NF}')
        echo "Starting the container $container_name"
        if [ "$2" == "1" ]; then
        docker start $container_name
        echo "Started the container $container_name"
        elif [ "$2" == "0" ]; then
        docker stop $container_name
        echo "Stopped the container $container_name"
        else
        echo "Invalid command option"
        fi

        echo "Stopping the WSS..."
        ;;
    R)
        echo "Starting the Redis (R)..."i
        container_name=$(docker ps -a | grep "my_redis"  | awk '{print $NF}')
        echo "Starting the container $container_name"
        if [ "$2" == "1" ]; then
        docker start $container_name
        echo "Started the container $container_name"
        elif [ "$2" == "0" ]; then
        docker stop $container_name
        echo "Stopped the container $container_name"
        else
        echo "Invalid command option"
        fi

        ;;
    DB)
        echo "Starting MySql Database (DB) ...."
        container_name=$(docker ps -a | grep "webservice_master"  | awk '{print $NF}')
        echo "Starting the container $container_name"
        if [ "$2" == "1" ]; then
        docker start $container_name
        echo "Started the container $container_name"
        elif [ "$2" == "0" ]; then
        docker stop $container_name
        echo "Stopped the container $container_name"
        else
        echo "Invalid command option"
        fi

        ;;
    OMSM)
            echo "Starting the Master OMS (OMSM) ..."
        container_name=$(docker ps -a | grep "webservice_master"  | awk '{print $NF}')
        echo "Starting the container $container_name"
        if [ "$2" == "1" ]; then
        docker start $container_name
        echo "Started the container $container_name"
        elif [ "$2" == "0" ]; then
        docker stop $container_name
        echo "Stopped the container $container_name"
        else
        echo "Invalid command option"
        fi

        ;;
    OMSS)
            echo "Starting the Slave OMS (OMSS) ..."
        container_name=$(docker ps -a | grep "webservice_master"  | awk '{print $NF}')
        echo "Starting the container $container_name"
        if [ "$2" == "1" ]; then
        docker start $container_name
        echo "Started the container $container_name"
        elif [ "$2" == "0" ]; then
        docker stop $container_name
        echo "Stopped the container $container_name"
        else
        echo "Invalid command option"
        fi

        ;;
    *)
        echo "Invalid command option"
        ;;
esac
