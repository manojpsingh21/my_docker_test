append=`date "+%Y%m%d_%H%M"`
append1=`date`
echo "stop OMS"
pwd
cd $HOME/Application/Exec/MonitoringTools
pwd
./StopApplication.sh
echo "sucessfully stop OMS"

sleep 10
cd $HOME/Application/Exec/MonitoringTools/
./StartApplication.sh
echo "sucessfully start OMS"

sleep 10
if test "$1 " = "1 "; then
	./ConnectExch.sh NSEEQ
	echo "Started NseCMExchAdap"
	./ConnectExch.sh NSEDR
	echo "Started NseFOExchAdap"
	#./ConnectExch.sh NSECUR
	#echo "Start CNseConAdap"
	./ConnectExch.sh BSEEQ
	echo "Started BseCMExchAdap"
	./ConnectExch.sh BSECUR
	echo "Started BseCDExchAdap"
fi;

