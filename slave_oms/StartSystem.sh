#################################################################################################
#            STARTSYSTEM.SH
#################################################################################################

#------------------------------------------------------------------------------------------------
#		CONFIGURATION NOTE
#------------------------------------------------------------------------------------------------

# NSECM - Variable which will start Process related to Nse Equity Segment for Transaction 
# Broadcast and Order Pumping.

# NSEFO - Variable which will start Process related to Nse Derivative Segment for Transaction
# Broadcast and Order Pumping.

# NSECD - Variable which will start Process related to Nse Currency Segment for Transaction
# Broadcast and Order Pumping.

# BSECM - Variable which will start Process related to Bse Equity Segment for Transaction
# Broadcast and Order Pumping.

# BSECD - Variable which will start Process related to Bse Currency Segment for Transaction
# Broadcast and Order Pumping.

# MCX - Variable which will start Process related to Mcx Commodity Segment for Transaction
# Broadcast and Order Pumping.

#COMMON - Variable which will start processes which are common for all.

#MISC - Variable which will start specific processes.

# 1.Define segment wise variable in START_EXCH_PROCESS in rupeeseed.env file to start processes.
# 2.Use - as a seperator between the variables, don't use any other special character as a seperator
#   Keeping same seprator will help us to know if the defined variables are proper/improper.
# 3.Define the variables as shown above , All Variables in UPPER_CASE.
# 4.Using Lower case alphabet in between or at the start/end of the variable will have an impact
#   due to which the script will try to compare the string and fail hence the process will not start.
# 5.IF in case the process did not get started then please check the defined variable in Script once.


#-----------------------------------------------------------------------------------------------
#               STARTING THE COMPLETE APPLICATION
#-----------------------------------------------------------------------------------------------

LOGDIR="$HOME/Application/Exec/Log"
export LOGDIR;
pwd
cd $HOME/Application/Exec/Run
if test "$1 " = " "; then

        CreateSeed >> $LOGDIR/CreateSeed.log
        if test $? -ne 0; then
                echo "CreateSeed failed"
        exit;
        fi;

        CreateSeedBcast >>  $LOGDIR/CreateSeedBcast.log
        if test $? -ne 0; then
                echo "CreateSeedBcast failed"
        exit;
        fi;


        rm -f $HOME/Application/Exec/MemMapFiles/*
        rm -f core*

        sleep 5

MAX_NO_OF_PARENT=9
#-------------------------------------------------------------------------
#       AUTOMATIC START OF PROGRAMS
#------------------------------------------------------------------------

        Debugger 3
        if test "$MASTER_SLAVE " = "M "; then
                CreateFile A $RRFILE_PATH >$LOGDIR/log.CreateFile 2>&1&
		CreateFileSock  A $RRFILE_PATH >$LOGDIR/log.CreateFileSock  2>&1&
                InMemTable 20 >$LOGDIR/log.InMemtable 2>&1&
        fi;

#----------------------------------------------------------------------------
#       FRONT END ADAPTORS
#---------------------------------------------------------------------------

        if test "$MASTER_SLAVE " = "M "; then
                RunProcess AdminAdptr $ADMIN_MAIN_PORT_SEC $ADMIN_CONNECT_PORT_SEC 4  AdminAdptr >$LOGDIR/log.AdminAdptr 2>&1&
        fi;

                RunProcess WebAdaptor $WEBADAPTER_PORT 1 5632 "180.179.25.24" "my_linux_slave_one" WebAdaptor  >$LOGDIR/log.WebAdaptor 2>&1&

#---------------------------------------------------------------------------
#       ROUTER
#---------------------------------------------------------------------------

        RunProcess OrderRouter OrderRouter >$LOGDIR/log.OrderRouter  2>&1&
        RunProcess TradeRouter TradeRouter >$LOGDIR/log.TradeRouter 2>&1&
        if test "$MASTER_SLAVE " = "M "; then
                RunProcess ENTrdRtToAdmAdp  ENTrdRtToAdmAdp >$LOGDIR/log.ENTrdRtToAdmAdp 2>&1&
        fi;
        RunProcess ENTrdRtToD2C1 ENTrdRtToD2C1 >$LOGDIR/log.ENTrdRtToD2C1 2>&1&
        RunProcess ENTrdRtToDWSAdp ENTrdRtToDWSAdp >$LOGDIR/log.ENTrdRtToDWSAdp 2>&1&
        RunProcess DWSTrdRtr DWSTrdRtr >$LOGDIR/log.DWSTrdRtr 2>&1&
        RunProcess AdminTrdRtr AdminTrdRtr >$LOGDIR/log.AdminTrdRtr 2>&1&

#---------------------------------------------------------------------------------------
#       QUERIES
#--------------------------------------------------------------------------------------

        if test "$MASTER_SLAVE " = "M "; then
                ln -s -f AdminQueries  AdminQueries_1
                ln -s -f AdminQueries  AdminQueries_2
                ln -s -f AdminQueries  AdminQueries_3
		ln -s -f DWSAdaptor    DWSAdaptor_1
                ln -s -f DWSAdaptor    DWSAdaptor_2
                RunProcess AdminQueries_1 AdminQueries_1 >$LOGDIR/log.AdminQueries_1 2>&1&
                RunProcess AdminQueries_2 AdminQueries_2 >$LOGDIR/log.AdminQueries_2 2>&1&
                RunProcess AdminQueries_3 AdminQueries_3 >$LOGDIR/log.AdminQueries_3 2>&1&
                RunProcess AdminUpdInsQry AdminUpdInsQry >$LOGDIR/log.AdminUpdInsQry 2>&1&
		RunProcess DWSAdaptor_1 $DWS_MAIN_PORT_PRI $DWS_CONNECT_PORT_PRI 0  DWSAdaptor_1 >$LOGDIR/log.DWSAdaptor_1 2>&1&
                RunProcess DWSAdaptor_2 $DWS_MAIN_PORT_SEC $DWS_CONNECT_PORT_SEC 4  DWSAdaptor_2 >$LOGDIR/log.DWSAdaptor_2 2>&1&
                RunProcess KafkaAdaptor $RS_KAFKA_HOST_PORT 2 $KAFKA_NOTIFY_TOPIC KAFKA KafkaAdaptor >$LOGDIR/log.KafkaAdaptor 2>&1&
                RunProcess DWSD2C1 $DWS_D2C1_PORT_PRI $DD2C1_CONNECT_PORT_PRI 0  DWSD2C1 >$LOGDIR/log.DWSD2C1 2>&1&
        fi;

#---------------------------------------------------------------------------------------
#       BSE
#---------------------------------------------------------------------------------------

if [[ $START_EXCH_PROCESS == *"BSECM"* ]];then


        #-------------------------------------------------------------------------
        #       BROADCAST PROCESS
        #-------------------------------------------------------------------------


        if test "$MASTER_SLAVE " = "M "; then
                RunProcess BseCMBcastAdap 2363 $BSE_BCAST_RECV_PORT L  EquBseDump.dmp  N EquBse23feb2012.dmp $BEQU_BROADCAST_TYPE BseCMBcastAdap >/dev/null 2>&1&
                RunProcess BseCMBcastSptr  BseCMBcastSptr >$LOGDIR/log.BseCMBcastSptr 2>&1&
                RunProcess BseCMMktStat BseCMMktStat >$LOGDIR/log.BseCMMktStat 2>&1&
                RunProcess BseCMSAddMbpUpd $MAX_NEQ_MBP_THREAD 1  BseCMSAddMbpUpd >/dev/null 2>&1&
                RunProcess BseCMSMemMbpUpd $MAX_NEQ_MBP_THREAD 1  BseCMSMemMbpUpd >/dev/null 2>&1&

        fi;

        #-------------------------------------------------------------------------
        #       TRANSACTION PROCESS
        #-------------------------------------------------------------------------

        RunProcess BseCMFwdMemMap BseCMFwdMemMap >$LOGDIR/log.BseCMFwdMemMap 2>&1&
        RunProcess BseAdapToRevMMap BseAdapToRevMMap >$LOGDIR/log.BseAdapToRevMMap 2>&1&

        MAX_NO_OF_PARENT=$INSTANCE_BSE_EQ
        RunProcess BseCMCatalyst $MAX_NO_OF_PARENT  BseCMCatalyst >$LOGDIR/log.BseCMCatalyst 2>&1&
while [ $MAX_NO_OF_PARENT -ne 0 ]; do
        ln -s -f BseCMOrdSvr BseCMOrdSvr_$MAX_NO_OF_PARENT;
        RunProcess BseCMOrdSvr_$MAX_NO_OF_PARENT $MAX_NO_OF_PARENT BseCMOrdSvr_$MAX_NO_OF_PARENT  >$LOGDIR/log.BseCMOrdSvr_$MAX_NO_OF_PARENT 2>&1&
        MAX_NO_OF_PARENT=`expr $MAX_NO_OF_PARENT - 1`
done;

        MAX_NO_OF_PARENT=9
        RunProcess BseCMRevMap $MAX_NO_OF_PARENT BseCMRevMap >$LOGDIR/log.BseCMRevMap 2>&1&
while [ $MAX_NO_OF_PARENT -ne 0 ]; do
        ln -s -f BseCMRevMemMap BseCMRevMemMap_$MAX_NO_OF_PARENT;
        ln -s -f BseCMTrdSvr BseCMTrdSvr_$MAX_NO_OF_PARENT;
        RunProcess BseCMRevMemMap_$MAX_NO_OF_PARENT $MAX_NO_OF_PARENT  BseCMRevMemMap_$MAX_NO_OF_PARENT  >$LOGDIR/log.BseCMRevMemMap_$MAX_NO_OF_PARENT 2>&1&
        RunProcess BseCMTrdSvr_$MAX_NO_OF_PARENT $MAX_NO_OF_PARENT  5 3 BseCMTrdSvr_$MAX_NO_OF_PARENT  >$LOGDIR/log.BseCMTrdSvr_$MAX_NO_OF_PARENT 2>&1&
        MAX_NO_OF_PARENT=`expr $MAX_NO_OF_PARENT - 1`
done;

	#-------------------------------------------------------------------------
	#       CO BO PUMPER
	#-------------------------------------------------------------------------

	RunProcess BseCMCOBOPump 0 BseCMCOBOPump >$LOGDIR/log.BseCMCOBOPump 2>&1&

else
        echo "BSECM is not added in rupeeseed.env in Varaible START_EXCH_PROCESS.Please add this to start BSE CM Process or ignore this message "
fi;


#---------------------------------------------------------------------------------------
#       BSE
#---------------------------------------------------------------------------------------


if [[ $START_EXCH_PROCESS == *"BSECD"* ]];then


        #-------------------------------------------------------------------------
        #       BROADCAST PROCESS
        #-------------------------------------------------------------------------

        if test "$MASTER_SLAVE " = "M "; then
                #RunProcess BseCDBcastAdap 2364 $BSE_BCAST_RECV_PORT L  EquBseDump.dmp  N EquBse23feb2012.dmp $BCURR_BROADCAST_TYPE BseCDBcastAdap >/dev/null 2>&1&
                RunProcess BseCDBcastAdap 2363 5451 L  EquBseDump.dmp  N EquBse23feb2012.dmp  B  BseCDBcastAdap >/dev/null 2>&1&
		RunProcess BseCDBcastSptr  BseCDBcastSptr >$LOGDIR/log.BseCDBcastSptr 2>&1&
                RunProcess BseCDMktStat BseCDMktStat >$LOGDIR/log.BseCDMktStat 2>&1&
                RunProcess BseCDSAddMbpUpd $MAX_NEQ_MBP_THREAD 1  BseCDSAddMbpUpd >/dev/null 2>&1&
                RunProcess BseCDSMemMbpUpd $MAX_NEQ_MBP_THREAD 1  BseCDSMemMbpUpd >/dev/null 2>&1&

        fi;

        #-------------------------------------------------------------------------
        #       TRANSACTION PROCESS
        #-------------------------------------------------------------------------

	RunProcess BseCDFwdMemMap BseCDFwdMemMap >$LOGDIR/log.BseCDFwdMemMap 2>&1&

        MAX_NO_OF_PARENT=9
        RunProcess BseCDCatalyst $MAX_NO_OF_PARENT  BseCDCatalyst >$LOGDIR/log.BseCDCatalyst 2>&1&
while [ $MAX_NO_OF_PARENT -ne 0 ]; do
        ln -s -f BseCDOrdSvr BseCDOrdSvr_$MAX_NO_OF_PARENT;
        RunProcess BseCDOrdSvr_$MAX_NO_OF_PARENT $MAX_NO_OF_PARENT BseCDOrdSvr_$MAX_NO_OF_PARENT  >$LOGDIR/log.BseCDOrdSvr_$MAX_NO_OF_PARENT 2>&1&
        MAX_NO_OF_PARENT=`expr $MAX_NO_OF_PARENT - 1`
done;

        MAX_NO_OF_PARENT=9
        RunProcess BseCDRevMap $MAX_NO_OF_PARENT BseCDRevMap >$LOGDIR/log.BseCDRevMap 2>&1&
while [ $MAX_NO_OF_PARENT -ne 0 ]; do
        ln -s -f BseCDRevMemMap BseCDRevMemMap_$MAX_NO_OF_PARENT;
        ln -s -f BseCDTrdSvr BseCDTrdSvr_$MAX_NO_OF_PARENT;
        RunProcess BseCDRevMemMap_$MAX_NO_OF_PARENT $MAX_NO_OF_PARENT  BseCDRevMemMap_$MAX_NO_OF_PARENT  >$LOGDIR/log.BseCDRevMemMap_$MAX_NO_OF_PARENT 2>&1&
        RunProcess BseCDTrdSvr_$MAX_NO_OF_PARENT $MAX_NO_OF_PARENT  5 3 BseCDTrdSvr_$MAX_NO_OF_PARENT  >$LOGDIR/log.BseCDTrdSvr_$MAX_NO_OF_PARENT 2>&1&
        MAX_NO_OF_PARENT=`expr $MAX_NO_OF_PARENT - 1`
done;

	#-------------------------------------------------------------------------
        #       CO BO PUMPER
        #-------------------------------------------------------------------------
		
	RunProcess BseCDCOBOPump 0 BseCDCOBOPump >$LOGDIR/log.BseCDCOBOPump 2>&1&	
	
else
        echo "BSECD is not added in rupeeseed.env in Varaible START_EXCH_PROCESS.Please add this to start BSE CD Process or ignore this message "
fi;


#-----------------------BSE FNO -------------------------------------------------------------------

if [[ $START_EXCH_PROCESS == *"BSEFO"* ]];then


        #-------------------------------------------------------------------------
        #       BROADCAST PROCESS
        #-------------------------------------------------------------------------


        if test "$MASTER_SLAVE " = "M "; then
                RunProcess BseFOBcastAdap 2363 $BSE_FO_BCAST_RECV_PORT L  EquBseDump.dmp  N EquBse23feb2012.dmp BseFOBcastAdap >/dev/null 2>&1&
                RunProcess BseFOBcastSptr  BseFOBcastSptr >$LOGDIR/log.BseFOBcastSptr 2>&1&
                RunProcess BseFOMktStat BseFOMktStat >$LOGDIR/log.BseFOMktStat 2>&1&
                RunProcess BseFOSAddMbpUpd $MAX_NEQ_MBP_THREAD 1  BseFOSAddMbpUpd >/dev/null 2>&1&
                RunProcess BseFOSMemMbpUpd $MAX_NEQ_MBP_THREAD 1  BseFOSMemMbpUpd >/dev/null 2>&1&

        fi;

        #-------------------------------------------------------------------------
        #       TRANSACTION PROCESS
        #-------------------------------------------------------------------------

        #RunProcess BseCMFwdMemMap BseCMFwdMemMap >$LOGDIR/log.BseCMFwdMemMap 2>&1&
        #RunProcess BseAdapToRevMMap BseAdapToRevMMap >$LOGDIR/log.BseAdapToRevMMap 2>&1&

        MAX_NO_OF_PARENT=$INSTANCE_BSE_FO
        RunProcess BseFOCatalyst $MAX_NO_OF_PARENT  BseFOCatalyst >$LOGDIR/log.BseFOCatalyst 2>&1&
while [ $MAX_NO_OF_PARENT -ne 0 ]; do
        ln -s -f BseFOOrdSvr BseFOOrdSvr_$MAX_NO_OF_PARENT;
        RunProcess BseFOOrdSvr_$MAX_NO_OF_PARENT $MAX_NO_OF_PARENT BseFOOrdSvr_$MAX_NO_OF_PARENT  >$LOGDIR/log.BseFOOrdSvr_$MAX_NO_OF_PARENT 2>&1&
        MAX_NO_OF_PARENT=`expr $MAX_NO_OF_PARENT - 1`
done;

        MAX_NO_OF_PARENT=9
        RunProcess BseFORevMap $MAX_NO_OF_PARENT BseFORevMap >$LOGDIR/log.BseFORevMap 2>&1&
while [ $MAX_NO_OF_PARENT -ne 0 ]; do
        ln -s -f BseFORevMemMap BseFORevMemMap_$MAX_NO_OF_PARENT;
        ln -s -f BseFOTrdSvr BseFOTrdSvr_$MAX_NO_OF_PARENT;
        RunProcess BseFORevMemMap_$MAX_NO_OF_PARENT $MAX_NO_OF_PARENT  BseFORevMemMap_$MAX_NO_OF_PARENT  >$LOGDIR/log.BseFORevMemMap_$MAX_NO_OF_PARENT 2>&1&
        RunProcess BseFOTrdSvr_$MAX_NO_OF_PARENT $MAX_NO_OF_PARENT  5 3 BseFOTrdSvr_$MAX_NO_OF_PARENT  >$LOGDIR/log.BseFOTrdSvr_$MAX_NO_OF_PARENT 2>&1&
        MAX_NO_OF_PARENT=`expr $MAX_NO_OF_PARENT - 1`
done;

        #-------------------------------------------------------------------------
        #       CO BO PUMPER
        #-------------------------------------------------------------------------

        RunProcess BseCMCOBOPump 0 BseCMCOBOPump >$LOGDIR/log.BseCMCOBOPump 2>&1&

else
        echo "BSECM is not added in rupeeseed.env in Varaible START_EXCH_PROCESS.Please add this to start BSE CM Process or ignore this message "
fi;



#---------------------------------------------------------------------------------------
#       MCX
#---------------------------------------------------------------------------------------

if [[ $START_EXCH_PROCESS == *"MCX"* ]];then
        
        #-------------------------------------------------------------------------
        #       BROADCAST PROCESS
        #-------------------------------------------------------------------------

        if test "$MASTER_SLAVE " = "M "; then
                RunProcess McxCOMBcastAdap $MCX_RECV_PORT L B  McxCOMBcastAdap >/dev/null 2>&1&
                RunProcess McxCOMSAddMbpUpd $MAX_NEQ_MBP_THREAD McxCOMSAddMbpUpd >/dev/null 2>&1&
                RunProcess McxCOMSMemMbpUpd $MAX_NEQ_MBP_THREAD McxCOMSMemMbpUpd >/dev/null 2>&1&
        fi;

        #-------------------------------------------------------------------------
        #       TRANSACTION PROCESS
        #-------------------------------------------------------------------------


	RunProcess McxCOMFwdMap $HOME/Application/Exec/ShellScripts/fixconfig.cfg M  McxCOMFwdMap >$LOGDIR/log.McxCOMFwdMap  2>&1&
        ##RunProcess McxCOMFwdMemMap McxCOMFwdMemMap >$LOGDIR/log.McxCOMFwdMemMap 2>&1&

MAX_NO_OF_PARENT=$INSTANCE_MCX_COM
        RunProcess McxCOMCatalyst $MAX_NO_OF_PARENT  McxCOMCatalyst >$LOGDIR/log.McxCOMCatalyst 2>&1&
while [ $MAX_NO_OF_PARENT -ne 0 ]; do
        ln -s -f McxCOMOrdSvr McxCOMOrdSvr_$MAX_NO_OF_PARENT;
        RunProcess McxCOMOrdSvr_$MAX_NO_OF_PARENT  $MAX_NO_OF_PARENT McxCOMOrdSvr_$MAX_NO_OF_PARENT >$LOGDIR/log.McxCOMOrdSvr_$MAX_NO_OF_PARENT 2>&1&
        MAX_NO_OF_PARENT=`expr $MAX_NO_OF_PARENT - 1`
done;

MAX_NO_OF_PARENT=9
        RunProcess McxCOMRevMap $MAX_NO_OF_PARENT McxCOMRevMap >$LOGDIR/log.McxCOMRevMap 2>&1&
while [ $MAX_NO_OF_PARENT -ne 0 ]; do
        ln -s -f McxCOMTrdSvr McxCOMTrdSvr_$MAX_NO_OF_PARENT;
        RunProcess McxCOMTrdSvr_$MAX_NO_OF_PARENT $MAX_NO_OF_PARENT 5 3 McxCOMTrdSvr_$MAX_NO_OF_PARENT >$LOGDIR/log.McxCOMTrdSvr_$MAX_NO_OF_PARENT 2>&1&
        MAX_NO_OF_PARENT=`expr $MAX_NO_OF_PARENT - 1`
done;


        #-------------------------------------------------------------------------
        #       CO BO PUMPER
        #-------------------------------------------------------------------------

	RunProcess McxCOBOPump 1  McxCOBOPump >$LOGDIR/log.McxCOBOPump 2>&1&


else
        echo "MCX is not added in rupeeseed.env in Varaible START_EXCH_PROCESS.Please add this to start MCX  Process or ignore this message "
fi;


#--------------------------------------------------------------------------------------
#       NSE
#-------------------------------------------------------------------------------------

#-----------------------------------------------------------
#       CM
#-----------------------------------------------------------
if [[ $START_EXCH_PROCESS == *"NSECM"* ]];then


        #-------------------------------------------------------------------------
        #       BROADCAST PROCESS
        #-------------------------------------------------------------------------

	if test "$MASTER_SLAVE " = "M "; then
                RunProcess NseCMBcastAdap $EQU_MULTICAST_GRP $EQU_MULTICAST_PORT L N $EQU_BROADCAST_TYPE $EQU_RECV_IP NseCMBcastAdap >/dev/null 2>&1&
                RunProcess NseCMBcastSptr NseCMBcastSptr >/dev/null 2>&1&
                RunProcess NseCMIndxUpldr NseCMIndxUpldr >/dev/null 2>&1&
                RunProcess NseCMMktStsUpdtr NseCMMktStsUpdtr >$LOGDIR/log.NseCMMktStsUpdtr 2>&1&
                RunProcess NseCMSAddMbpUpd 1 1 NseCMSAddMbpUpd >/dev/null 2>&1&
                RunProcess NseCMSMemMbpUpd $MAX_NEQ_MBP_THREAD 1 NseCMSMemMbpUpd >/dev/null 2>&1&
                RunProcess NseCMSAddMktStsUpd 1 5 NseCMSAddMktStsUpd >$LOGDIR/log.NseCMSAddMktStsUpd 2>&1&
                RunProcess NseCMSMemMktStsUpd 1 1 NseCMSMemMktStsUpd >$LOGDIR/log.NseCMSMemMktStsUpd 2>&1&
	fi;


	#-------------------------------------------------------------------------
        #       TRANSACTION PROCESS
        #-------------------------------------------------------------------------

        RunProcess NseCMFwdMap NseCMFwdMap >$LOGDIR/log.NseCMFwdMap 2>&1&
        RunProcess NseCMAdapMMap NseCMAdapMMap >$LOGDIR/log.NseCMAdapMMap 2>&1&
        RunProcess NseCMFwdMemMap NseCMFwdMemMap >$LOGDIR/log.NseCMFwdMemMap 2>&1&

MAX_NO_OF_PARENT=$INSTANCE_NSE_EQ
        RunProcess NseCMCatalyst $MAX_NO_OF_PARENT  NseCMCatalyst >$LOGDIR/log.NseCMCatalyst 2>&1&
while [ $MAX_NO_OF_PARENT -ne 0 ]; do
        ln -s -f NseCMOrdSvr NseCMOrdSvr_$MAX_NO_OF_PARENT;
        RunProcess NseCMOrdSvr_$MAX_NO_OF_PARENT $MAX_NO_OF_PARENT NseCMOrdSvr_$MAX_NO_OF_PARENT  >$LOGDIR/log.NseCMOrdSvr_$MAX_NO_OF_PARENT 2>&1&
        MAX_NO_OF_PARENT=`expr $MAX_NO_OF_PARENT - 1`
done;


MAX_NO_OF_PARENT=9
        RunProcess NseCMRevCatalyst $MAX_NO_OF_PARENT  NseCMRevCatalyst >$LOGDIR/log.NseCMRevCatalyst 2>&1&
while [ $MAX_NO_OF_PARENT -ne 0 ]; do
        ln -s -f NseCMTrdSvr NseCMTrdSvr_$MAX_NO_OF_PARENT;
        ln -s -f NseCMRevMap NseCMRevMap_$MAX_NO_OF_PARENT;
        ln -s -f NseCMRevCatMMap NseCMRevCatMMap_$MAX_NO_OF_PARENT;
        RunProcess NseCMRevCatMMap_$MAX_NO_OF_PARENT $MAX_NO_OF_PARENT NseCMRevCatMMap_$MAX_NO_OF_PARENT >$LOGDIR/log.NseCMRevCatMMap_$MAX_NO_OF_PARENT 2>&1&
        RunProcess NseCMRevMap_$MAX_NO_OF_PARENT $MAX_NO_OF_PARENT NseCMRevMap_$MAX_NO_OF_PARENT >$LOGDIR/log.NseCMRevMap_$MAX_NO_OF_PARENT 2>&1&
        RunProcess NseCMTrdSvr_$MAX_NO_OF_PARENT $MAX_NO_OF_PARENT  5 3 NseCMTrdSvr_$MAX_NO_OF_PARENT  >$LOGDIR/log.NseCMTrdSvr_$MAX_NO_OF_PARENT 2>&1&
        MAX_NO_OF_PARENT=`expr $MAX_NO_OF_PARENT - 1`
done;


	#-------------------------------------------------------------------------
	#       CO BO PUMPER
	#-------------------------------------------------------------------------

MAX_NO_OF_PARENT=3
while [ $MAX_NO_OF_PARENT -ne 0 ]; do
        ln -s -f NseCMCOBOPump NseCMCoPump_$MAX_NO_OF_PARENT;
        RunProcess NseCMCoPump_$MAX_NO_OF_PARENT $MAX_NO_OF_PARENT V NseCMCoPump_$MAX_NO_OF_PARENT >$LOGDIR/log.NseCMCoPump_$MAX_NO_OF_PARENT 2>&1&
        MAX_NO_OF_PARENT=`expr $MAX_NO_OF_PARENT - 1`
done;

MAX_NO_OF_PARENT=5
while [ $MAX_NO_OF_PARENT -ne 0 ]; do
        ln -s -f NseCMCOBOPump NseCMBoPump_$MAX_NO_OF_PARENT;
        RunProcess NseCMBoPump_$MAX_NO_OF_PARENT $MAX_NO_OF_PARENT B NseCMBoPump_$MAX_NO_OF_PARENT >$LOGDIR/log.NseCMBoPump_$MAX_NO_OF_PARENT 2>&1&
        MAX_NO_OF_PARENT=`expr $MAX_NO_OF_PARENT - 1`
done;

else
        echo "NSECM is not added in rupeeseed.env in Varaible START_EXCH_PROCESS.Please add this to start NSE CM Process or ignore this message "
fi;

#-----------------------------------------------------------
#       FO
#-----------------------------------------------------------

if [[ $START_EXCH_PROCESS == *"NSEFO"* ]];then

        #-------------------------------------------------------------------------
        #       BROADCAST PROCESS
        #-------------------------------------------------------------------------
        if test "$MASTER_SLAVE " = "M "; then

                RunProcess NseFOBcastAdap  $DRV_MULTICAST_GRP $DRV_MULTICAST_PORT L N $DRV_BROADCAST_TYPE $DRV_RECV_IP NseFOBcastAdap >/dev/null 2>&1&
                RunProcess NseFOBcastSptr NseFOBcastSptr >/dev/null 2>&1&
                RunProcess NseFOMktStsUpdtr NseFOMktStsUpdtr >/dev/null 2>&1&
                RunProcess NseFOSAddMbpUpd $MAX_NEQ_MBP_THREAD  1 NseFOSAddMbpUpd >/dev/null 2>&1&
                RunProcess NseFOSMemMbpUpd 1 1 NseFOSMemMbpUpd >/dev/null 2>&1&
                RunProcess NseFOSAddDPRUpd 1  NseFOSAddDPRUpd >$LOGDIR/log.NseFOSAddDPRUpd 2>&1&
                RunProcess NseFOSMemDPRUpd 1 1 NseFOSMemDPRUpd >$LOGDIR/log.NseFOSMemDPRUpd 2>&1&
	fi;


	#-------------------------------------------------------------------------
        #       TRANSACTION PROCESS
        #-------------------------------------------------------------------------

        RunProcess NseFOFwdMap NseFOFwdMap >$LOGDIR/log.NseFOFwdMap 2>&1&
        RunProcess NseFOFwdMemMap NseFOFwdMemMap >$LOGDIR/log.NseFOFwdMemMap 2>&1&

MAX_NO_OF_PARENT=$INSTANCE_NSE_FO
        RunProcess NseFOCatalyst $MAX_NO_OF_PARENT  NseFOCatalyst >$LOGDIR/log.NseFOCatalyst 2>&1&
while [ $MAX_NO_OF_PARENT -ne 0 ]; do
        ln -s -f NseFOOrdSvr NseFOOrdSvr_$MAX_NO_OF_PARENT;
        RunProcess NseFOOrdSvr_$MAX_NO_OF_PARENT  $MAX_NO_OF_PARENT NseFOOrdSvr_$MAX_NO_OF_PARENT >$LOGDIR/log.NseFOOrdSvr_$MAX_NO_OF_PARENT 2>&1&
        MAX_NO_OF_PARENT=`expr $MAX_NO_OF_PARENT - 1`
done;

MAX_NO_OF_PARENT=9
        RunProcess NseFORevMap $MAX_NO_OF_PARENT NseFORevMap >$LOGDIR/log.NseFORevMap 2>&1&
while [ $MAX_NO_OF_PARENT -ne 0 ]; do
        ln -s -f NseFOTrdSvr NseFOTrdSvr_$MAX_NO_OF_PARENT;
        RunProcess NseFOTrdSvr_$MAX_NO_OF_PARENT $MAX_NO_OF_PARENT 5 3 NseFOTrdSvr_$MAX_NO_OF_PARENT >$LOGDIR/log.NseFOTrdSvr_$MAX_NO_OF_PARENT 2>&1&
        MAX_NO_OF_PARENT=`expr $MAX_NO_OF_PARENT - 1`
done;


	#-------------------------------------------------------------------------
	#       CO BO PUMPER
	#-------------------------------------------------------------------------

MAX_NO_OF_PARENT=2
while [ $MAX_NO_OF_PARENT -ne 0 ]; do
        ln -s -f NseFOCOBOPump NseFOCOPump_$MAX_NO_OF_PARENT;
        RunProcess NseFOCOPump_$MAX_NO_OF_PARENT $MAX_NO_OF_PARENT V NseFOCOPump_$MAX_NO_OF_PARENT >$LOGDIR/log.NseFOCOPump_$MAX_NO_OF_PARENT 2>&1&
        MAX_NO_OF_PARENT=`expr $MAX_NO_OF_PARENT - 1`
done;

MAX_NO_OF_PARENT=3
while [ $MAX_NO_OF_PARENT -ne 0 ]; do
        ln -s -f NseFOCOBOPump NseFOBOPump_$MAX_NO_OF_PARENT;
        RunProcess NseFOBOPump_$MAX_NO_OF_PARENT $MAX_NO_OF_PARENT B NseFOBOPump_$MAX_NO_OF_PARENT >$LOGDIR/log.NseFOBOPump_$MAX_NO_OF_PARENT 2>&1&
        MAX_NO_OF_PARENT=`expr $MAX_NO_OF_PARENT - 1`
done;

else
        echo "NSEFO is not added in rupeeseed.env in Varaible START_EXCH_PROCESS.Please add this to start NSE FO process or ignore this message "
fi;


#-----------------------------------------------------------
#       CD
#-----------------------------------------------------------

if [[ $START_EXCH_PROCESS == *"NSECD"* ]];then


        #-------------------------------------------------------------------------
        #       BROADCAST PROCESS
        #-------------------------------------------------------------------------


        if test "$MASTER_SLAVE " = "M "; then

                RunProcess NseCDBcastAdap  $CURR_MULTICAST_GRP $CURR_MULTICAST_PORT L N $CURR_BROADCAST_TYPE $CURR_RECV_IP NseCDBcastAdap >/dev/null 2>&1&
                RunProcess NseCDBcastSptr NseCDBcastSptr >/dev/null  2>&1&
                RunProcess NseCDBMktStsUpdtr NseCDBMktStsUpdtr >/dev/null 2>&1&
                RunProcess NseCDSAddMbpUpd $MAX_NEQ_MBP_THREAD 1 NseCDSAddMbpUpd >$LOGDIR/log.NseCDSAddMbpUpd 2>&1&
                RunProcess NseCDSMemMbpUpd $MAX_NEQ_MBP_THREAD 1 NseCDSMemMbpUpd >$LOGDIR/log.NseCDSMemMbpUpd 2>&1&
                RunProcess NseCDSAddDPRUpd 1  NseCDSAddDPRUpd >/dev/null 2>&1&
                RunProcess NseCDSMemDPRUpd 1 5 NseCDSMemDPRUpd >$LOGDIR/log.NseCDSMemDPRUpd 2>&1&

        fi;

	#-------------------------------------------------------------------------
        #       TRANSACTION PROCESS
        #-------------------------------------------------------------------------

        RunProcess NseCDFwdMap NseCDFwdMap >$LOGDIR/log.NseCDFwdMap 2>&1&
        RunProcess NseCDFwdMemMap NseCDFwdMemMap >$LOGDIR/log.NseCDFwdMemMap 2>&1&
MAX_NO_OF_PARENT=$INSTANCE_NSE_CD
        RunProcess NseCDCatalyst $MAX_NO_OF_PARENT  NseCDCatalyst >$LOGDIR/log.NseCDCatalyst 2>&1&
while [ $MAX_NO_OF_PARENT -ne 0 ]; do
        ln -s -f NseCDOrdSvr NseCDOrdSvr_$MAX_NO_OF_PARENT;
        RunProcess NseCDOrdSvr_$MAX_NO_OF_PARENT  $MAX_NO_OF_PARENT NseCDOrdSvr_$MAX_NO_OF_PARENT >$LOGDIR/log.NseCDOrdSvr_$MAX_NO_OF_PARENT 2>&1&
        MAX_NO_OF_PARENT=`expr $MAX_NO_OF_PARENT - 1`
done;

MAX_NO_OF_PARENT=9
        RunProcess NseCDRevMap $MAX_NO_OF_PARENT NseCDRevMap >$LOGDIR/log.NseCDRevMap 2>&1&
while [ $MAX_NO_OF_PARENT -ne 0 ]; do
        ln -s -f NseCDTrdSvr NseCDTrdSvr_$MAX_NO_OF_PARENT;
        RunProcess NseCDTrdSvr_$MAX_NO_OF_PARENT $MAX_NO_OF_PARENT 5 3 NseCDTrdSvr_$MAX_NO_OF_PARENT >$LOGDIR/log.NseCDTrdSvr_$MAX_NO_OF_PARENT 2>&1&
        MAX_NO_OF_PARENT=`expr $MAX_NO_OF_PARENT - 1`
done;

else
        echo "NSECD is not added in rupeeseed.env in Varaible START_EXCH_PROCESS.Please add this to start NSE CD Process or ignore this message "
fi;


#--------------------------------------------------------------------------------------
#       COMMON
#-------------------------------------------------------------------------------------
if [[ $START_EXCH_PROCESS == *"COMMON"* ]];then


#--------------------------------------------------------------------------------------
#       INTRADAY SQUARE OFF SEGMENT-WISE
#--------------------------------------------------------------------------------------

if test "$MASTER_SLAVE " = "M "; then


	if [[ $START_EXCH_PROCESS == *"NSECM"* ]];then
		ln -s -f IntSqrOff  IntSqrOffNEq
		ln -s -f IntSqrOff  IntSqrOffCoNEq
		ln -s -f IntSqrOff  IntSqrOffBoNEq
	
		RunProcess IntSqrOffNEq 2  IntSqrOffNEq >$LOGDIR/log.IntSqrOffNEq 2>&1&
		RunProcess IntSqrOffCoNEq 5  IntSqrOffCoNEq >$LOGDIR/log.IntSqrOffCoNEq 2>&1&
		RunProcess IntSqrOffBoNEq 9 IntSqrOffBoNEq >$LOGDIR/log.IntSqrOffBoNEq 2>&1&		
	fi;
	
	if [[ $START_EXCH_PROCESS == *"NSEFO"* ]];then
		ln -s -f IntSqrOff  IntSqrOffNDrv
		ln -s -f IntSqrOff  IntSqrOffCoNDr
		ln -s -f IntSqrOff  IntSqrOffBoNDr
	
		RunProcess IntSqrOffNDrv 3  IntSqrOffNDrv >$LOGDIR/log.IntSqrOffNDrv 2>&1&
		RunProcess IntSqrOffCoNDr 6  IntSqrOffCoNDr >$LOGDIR/log.IntSqrOffCoNDr 2>&1&
		RunProcess IntSqrOffBoNDr 10 IntSqrOffBoNDr >$LOGDIR/log.IntSqrOffBoNDr 2>&1&	
		
	fi;

	if [[ $START_EXCH_PROCESS == *"NSECD"* ]];then
		ln -s -f IntSqrOff  IntSqrOffBoNCr
        	ln -s -f IntSqrOff  IntSqrOffCoNCr
	
		RunProcess IntSqrOffCoNCr 7 IntSqrOffCoNCr  >$LOGDIR/log.IntSqrOffCoNCr 2>&1&
        	RunProcess IntSqrOffBoNCr 11 IntSqrOffBoNCr >$LOGDIR/log.IntSqrOffBoNCr 2>&1&

	fi;


	if [[ $START_EXCH_PROCESS == *"BSECM"* ]];then
		ln -s -f IntSqrOff  IntSqrOffBEq
		ln -s -f IntSqrOff  IntSqrOffCoBEq
		ln -s -f IntSqrOff  IntSqrOffBoBEq

		RunProcess IntSqrOffBEq 1  IntSqrOffBEq >$LOGDIR/log.IntSqrOffBEq 2>&1&
		RunProcess IntSqrOffCoBEq 8 IntSqrOffCoBEq >$LOGDIR/log.IntSqrOffCoBEq  2>&1&
		RunProcess IntSqrOffBoBEq 12 IntSqrOffBoBEq >$LOGDIR/log.IntSqrOffBoBEq 2>&1&
        fi;
	
	if [[ $START_EXCH_PROCESS == *"MCX"* ]];then
		ln -s -f IntSqrOff  IntSqrOffMCom
		ln -s -f IntSqrOff  IntSqrOffCoMCom
        	ln -s -f IntSqrOff  IntSqrOffBoMCom	
		

		RunProcess IntSqrOffMCom 4  IntSqrOffMCom >$LOGDIR/log.IntSqrOffMCom 2>&1&
		RunProcess IntSqrOffCoMCom 13  IntSqrOffCoMCom >$LOGDIR/log.IntSqrOffCoMCom 2>&1&
        	RunProcess IntSqrOffBoMCom 14  IntSqrOffBoMCom >$LOGDIR/log.IntSqrOffBoMCom 2>&1&
	
	fi;

	if [[ $START_EXCH_PROCESS == *"BSECD"* ]];then
                ln -s -f IntSqrOff  IntSqrOffBCr
                ln -s -f IntSqrOff  IntSqrOffCoBCr
                ln -s -f IntSqrOff  IntSqrOffBoBCr

                RunProcess IntSqrOffBCr 16  IntSqrOffBCr >$LOGDIR/log.IntSqrOffBCr 2>&1&
                RunProcess IntSqrOffCoBCr 17 IntSqrOffCoBCr >$LOGDIR/log.IntSqrOffCoBCr  2>&1&
                RunProcess IntSqrOffBoBCr 18 IntSqrOffBoBCr >$LOGDIR/log.IntSqrOffBoBCr 2>&1&
        fi;


		ln -s -f IntSqrOff  IntBulkSqrOff
		ln -s -f IntSqrOff IntSqrOffBDrv 
		RunProcess IntBulkSqrOff 15 IntBulkSqrOff >$LOGDIR/log.IntBulkSqrOff 2>&1&
		RunProcess IntSqrOffBDrv 19 IntSqrOffBDrv >$LOGDIR/log.IntSqrOffBDrv 2>&1&

fi;


        MAX_NO_OF_PARENT=5
        while [ $MAX_NO_OF_PARENT -ne 0 ]; do
                ln -s -f NotiFyToFE NotiFyToFE_$MAX_NO_OF_PARENT;
                RunProcess NotiFyToFE_$MAX_NO_OF_PARENT $MAX_NO_OF_PARENT NotiFyToFE_$MAX_NO_OF_PARENT >$LOGDIR/log.NotiFyToFE_$MAX_NO_OF_PARENT 2>&1&
                MAX_NO_OF_PARENT=`expr $MAX_NO_OF_PARENT - 1`
        done;

        RunProcess OfflineOrders OfflineOrders >$LOGDIR/log.OfflineOrders 2>&1&
        RunProcess NotifyMMapToCatalyst 5 NotifyMMapToCatalyst >$LOGDIR/log.NotifyMMapToCatalyst 2>&1&
        RunProcess ENTrdRtrToRevVal 5 ENTrdRtrToRevVal >$LOGDIR/log.ENTrdRtrToRevVal 2>&1&
        RunProcess MemMapToCatalyst 9 MemMapToCatalyst >$LOGDIR/log.MemMapToCatalyst 2>&1&
        RunProcess MissedTrdMMap 1 MissedTrdMMap >$LOGDIR/log.MissedTrdMMap 2>&1&

        MAX_NO_OF_PARENT=9
        while [ $MAX_NO_OF_PARENT -ne 0 ]; do
                ln -s -f RMSRevVald RMSRevVald_$MAX_NO_OF_PARENT;
                RunProcess RMSRevVald_$MAX_NO_OF_PARENT $MAX_NO_OF_PARENT RMSRevVald_$MAX_NO_OF_PARENT >$LOGDIR/log.RMSRevVald_$MAX_NO_OF_PARENT 2>&1&
                MAX_NO_OF_PARENT=`expr $MAX_NO_OF_PARENT - 1`
        done;
        RunProcess MarginCaltr MarginCaltr >$LOGDIR/log.MarginCaltr 2>&1&
        RunProcess D2C1Router D2C1Router >/dev/null 2>&1&
        RunProcess ConvToDel ConvToDel >$LOGDIR/log.ConvToDel 2>&1&
        RunProcess SystemMsg SystemMsg >$LOGDIR/log.SystemMsg 2>&1&
        RunProcess ProcessMon ProcessMon >$LOGDIR/log.ProcessMon 2>&1&



        if test "$MASTER_SLAVE " = "M "; then
                RunProcess DealerNotify DealerNotify >$LOGDIR/log.DealerNotify 2>&1&
                RunProcess MTMChecker MTMChecker >$LOGDIR/log.MTMChecker 2>&1&
                RunProcess CKTChecker CKTChecker >$LOGDIR/log.CKTChecker 2>&1&
                RunProcess RupeeDaemon RupeeDaemon >$LOGDIR/log.RupeeDaemon 2>&1&
                RunProcess MarketDaemon MarketDaemon >$LOGDIR/log.MarketDaemon 2>&1&
                RunProcess ClientNotifyFE ClientNotifyFE >$LOGDIR/log.ClientNotifyFE 2>&1&
                RunProcess ServerDaemon $AUTO_DAEMON_PORT ServerDaemon >$LOGDIR/log.ServerDaemon 2>&1&
                RunProcess BulkOrdToDmonMMap BulkOrdToDmonMMap >$LOGDIR/log.BulkOrdToDmonMMap 2>&1&
        	RunProcess KFreadwrite $RS_KAFKA_HOST_PORT 1 $KAFKA_NOTIFY_TOPIC CHELSEAFC KFreadwrite >$LOGDIR/log.KFreadwrite 2>&1&
		RunProcess NotifyProcess NotifyProcess >$LOGDIR/log.NotifyProcess 2>&1&
	fi;
        if test "$MASTER_SLAVE " = "S "; then
                RunProcess CltDmonToOrdRtrMMap CltDmonToOrdRtrMMap >$LOGDIR/log.CltDmonToOrdRtrMMap 2>&1&
                RunProcess ClientDaemon $AUTO_DAEMON_PORT $AUTO_DAEMON_IP ClientDaemon >$LOGDIR/log.ClientDaemon 2>&1&
		RunProcess TradeNotifier 10 TradeNotifier >$LOGDIR/log.TradeNotifier 2>&1&
        fi;

else
        echo "COMMON is not added in rupeeseed.env in Varaible START_EXCH_PROCESS.Please add this to start COMMON Processes or ignore this message "
fi;


#------------------------------------------------------------------------
#	MISC
#------------------------------------------------------------------------
if [[ $START_EXCH_PROCESS == *"MISC"* ]];then



	RunProcess GTTOrders GTTOrders >$LOGDIR/log.GTTOrders 2>&1&
	RunProcess SIPEquity SIPEquity >$LOGDIR/log.SIPEquity 2>&1&

	if test "$MASTER_SLAVE " = "M "; then
		RunProcess PNLSpanDaemon 5  PNLSpanDaemon >$LOGDIR/log.PNLSpanDaemon 2>&1&
        	RunProcess GTTBrdcstProcess 1 2 GTTBrdcstProcess >$LOGDIR/log.GTTBrdcstProcess 2>&1&
        fi;



else
        echo "MISC is not added in rupeeseed.env in Varaible START_EXCH_PROCESS.Please add this to start MISCELLANEOUS Processes or ignore this message "
fi;

if test "$Q_STATUS " = "Y "; then
	
	if test "$MASTER_SLAVE " = "S "; then
       
		if [[ $START_EXCH_PROCESS == *"NSECM"* ]];then
                	ln -s -f OrderProcess  OrderProcessNEQ
			RunProcess OrderProcessNEQ 1 OrderProcessNEQ > $LOGDIR/log.OrderProcessNEQ 2>&1&
        	fi;

	        if [[ $START_EXCH_PROCESS == *"NSEFO"* ]];then
        	        ln -s -f OrderProcess  OrderProcessNFO
			RunProcess OrderProcessNFO 2 OrderProcessNFO > $LOGDIR/log.OrderProcessNFO 2>&1&
        	fi;

        	if [[ $START_EXCH_PROCESS == *"NSECD"* ]];then
                	ln -s -f OrderProcess  OrderProcessNCD
			RunProcess OrderProcessNCD 3 OrderProcessNCD > $LOGDIR/log.OrderProcessNCD 2>&1&
        	fi;

        	if [[ $START_EXCH_PROCESS == *"BSECM"* ]];then
                	ln -s -f OrderProcess  OrderProcessBEQ
			RunProcess OrderProcessBEQ 4 OrderProcessBEQ > $LOGDIR/log.OrderProcessBEQ 2>&1&
        	fi;

	        if [[ $START_EXCH_PROCESS == *"MCX"* ]];then
        	        ln -s -f OrderProcess  OrderProcessMCX
			RunProcess OrderProcessMCX 5 OrderProcessMCX > $LOGDIR/log.OrderProcessMCX 2>&1&
               
		fi;
	
	fi;
	
fi;



fi;
#-------------------------------------------------------------------------
#       MANUAL START OF PROGRAMS
#-------------------------------------------------------------------------



if test "$1 " = "DWSTrdRtr "; then
        RunProcess DWSTrdRtr DWSTrdRtr >$LOGDIR/log.DWSTrdRtr 2>&1&
fi;

if test "$1 " = "MtmBrchSqrOff "; then
        RunProcess MtmBrchSqrOff MtmBrchSqrOff >$LOGDIR/log.MtmBrchSqrOff 2>&1&
fi;

if test "$1 " = "OffPumper "; then
        RunProcess OffPumper  OffPumper >$LOGDIR/log.OffPumper 2>&1&
fi;

if test "$1 " = "FileMapper "; then
        FileMapper >$LOGDIR/log.FileMapper 2>&1&
fi;

if test "$1 " = "SystemMsg "; then
        RunProcess SystemMsg SystemMsg >$LOGDIR/log.SystemMsg 2>&1&
fi;

if test "$1 " = "McxCOMMbpUpd "; then
        RunProcess McxCOMMbpUpd $MAX_MCX_MBP_THREAD  McxCOMMbpUpd >$LOGDIR/log.McxCOMMbpUpd 2>&1&
fi;
if test "$1 " = "NseCMMbpUpd "; then
        RunProcess NseCMMbpUpd $MAX_NEQ_MBP_THREAD NseCMMbpUpd >$LOGDIR/log.NseCMMbpUpd 2>&1&
fi;

if test "$1 " = "NseCMBcastSptr "; then
        RunProcess NseCMBcastSptr NseCMBcastSptr >$LOGDIR/log.NseCMBcastSptr 2>&1&
fi;

if test "$1 " = "NseFOMktStsUpdtr "; then
        RunProcess NseFOMktStsUpdtr NseFOMktStsUpdtr >$LOGDIR/log.NseFOMktStsUpdtr 2>&1&
fi;

if test "$1 " = "NseCDBMktStsUpdtr "; then
        RunProcess NseCDBMktStsUpdtr NseCDBMktStsUpdtr >$LOGDIR/log.NseCDBMktStsUpdtr 2>&1&
fi;

if test "$1 " = "NseCMIndxUpldr "; then
        RunProcess NseCMIndxUpldr NseCMIndxUpldr >$LOGDIR/log.NseCMIndxUpldr 2>&1&
fi;

if test "$1 " = "NseFOMbpUpd "; then
        RunProcess NseFOMbpUpd $MAX_NFO_MBP_THREAD NseFOMbpUpd >$LOGDIR/log.NseFOMbpUpd 2>&1&
fi;

if test "$1 " = "NseCDMbpUpd "; then
        RunProcess NseCDMbpUpd $MAX_NCD_MBP_THREAD NseCDMbpUpd >$LOGDIR/log.NseCDMbpUpd 2>&1&
fi;

if test "$1 " = "NseFOBcastSptr "; then
        RunProcess NseFOBcastSptr NseFOBcastSptr >$LOGDIR/log.NseFOBcastSptr 2>&1&
fi;

if test "$1 " = "NseCDBcastSptr "; then
        RunProcess NseCDBcastSptr NseCDBcastSptr >$LOGDIR/log.NseCDBcastSptr 2>&1&
fi;

if test "$1 " = "DWSQueries_1 "; then
        RunProcess DWSQueries_1 DWSQueries_1  >$LOGDIR/log.DWSQueries_1 2>&1&
fi;

if test "$1 " = "DWSQueries_2 "; then
        RunProcess DWSQueries_2 DWSQueries_2  >$LOGDIR/log.DWSQueries_2 2>&1&
fi;

if test "$1 " = "DWSQueries_3 "; then
        RunProcess DWSQueries_3 DWSQueries_3  >$LOGDIR/log.DWSQueries_3 2>&1&
fi;

if test "$1 " = "ENBcastSplitter "; then
        RunProcess ENBcastSplitter ENBcastSplitter >$LOGDIR/log.ENBcastSplitter 2>&1&
fi;

if test "$1 " = "ENMbpUploader "; then
        RunProcess ENMbpUploader ENMbpUploader >$LOGDIR/log.ENMbpUploader 2>&1&
fi;

if test "$1 " = "DWSRelay_1 "; then
        RunProcess DWSRelay_1 $DWS_MAIN_PORT_PRI $DWS_CONNECT_PORT_PRI 0  DWSRelay_1 >$LOGDIR/log.DWSRelay_1 2>&1&
fi;

if test "$1 " = "DWSRelay_2 "; then
        RunProcess DWSRelay_2 $DWS_MAIN_PORT_SEC $DWS_CONNECT_PORT_SEC 4  DWSRelay_2 >$LOGDIR/log.DWSRelay_2 2>&1&
fi;

if test "$1 " = "WebAdaptor "; then
        RunProcess WebAdaptor  $WEBADAPTER_PORT 1 5632 "192.168.2.91" "my_linux_slave_one" WebAdaptor  >$LOGDIR/log.WebAdaptor 2>&1&
fi;

if test "$1 " = "OrderRouter "; then
        RunProcess OrderRouter OrderRouter >$LOGDIR/log.OrderRouter  2>&1&
fi;

#if test "$1 " = "McxCOMOrdSvr "; then
#        RunProcess McxCOMOrdSvr 1  McxCOMOrdSvr >$LOGDIR/log.McxCOMOrdSvr  2>&1&
#fi;


if test "$1 " = "NseFOCatalyst "; then
        RunProcess NseFOCatalyst $INSTANCE_NSE_FO NseFOCatalyst >$LOGDIR/log.NseFOCatalyst 2>&1&
fi;

if test "$1 " = "MemMapToCatalyst "; then
        RunProcess MemMapToCatalyst 9 MemMapToCatalyst >$LOGDIR/log.MemMapToCatalyst 2>&1&
fi;

if test "$1 " = "NseFOOrdSvr_1 "; then
        RunProcess NseFOOrdSvr_1 1 NseFOOrdSvr_1 >$LOGDIR/log.NseFOOrdSvr_1  2>&1&
fi;

if test "$1 " = "NseFOOrdSvr_2 "; then
        RunProcess NseFOOrdSvr_2 2 NseFOOrdSvr_2 >$LOGDIR/log.NseFOOrdSvr_2  2>&1&
fi;

if test "$1 " = "NseFOOrdSvr_3 "; then
        RunProcess NseFOOrdSvr_3 3 NseFOOrdSvr_3 >$LOGDIR/log.NseFOOrdSvr_3  2>&1&
fi;

if test "$1 " = "NseFOOrdSvr_4 "; then
        RunProcess NseFOOrdSvr_4 4 NseFOOrdSvr_4 >$LOGDIR/log.NseFOOrdSvr_4  2>&1&
fi;

if test "$1 " = "NseFOOrdSvr_5 "; then
        RunProcess NseFOOrdSvr_5 5 NseFOOrdSvr_5 >$LOGDIR/log.NseFOOrdSvr_5  2>&1&
fi;
if test "$1 " = "NseFOOrdSvr_6 "; then
        RunProcess NseFOOrdSvr_6 6 NseFOOrdSvr_6 >$LOGDIR/log.NseFOOrdSvr_6  2>&1&
fi;
if test "$1 " = "NseFOOrdSvr_7 "; then
        RunProcess NseFOOrdSvr_7 7 NseFOOrdSvr_7 >$LOGDIR/log.NseFOOrdSvr_7  2>&1&
fi;
if test "$1 " = "NseFOOrdSvr_8 "; then
        RunProcess NseFOOrdSvr_8 8 NseFOOrdSvr_8 >$LOGDIR/log.NseFOOrdSvr_8  2>&1&
fi;
if test "$1 " = "NseFOOrdSvr_9 "; then
        RunProcess NseFOOrdSvr_9 9 NseFOOrdSvr_9 >$LOGDIR/log.NseFOOrdSvr_9  2>&1&
fi;

if test "$1 " = "NseFOOrdSvr_10 "; then
        RunProcess NseFOOrdSvr_10 10 NseFOOrdSvr_10 >$LOGDIR/log.NseFOOrdSvr_10  2>&1&
fi;
	
if test "$1 " = "NseFOOrdSvr_11 "; then
        RunProcess NseFOOrdSvr_11 11 NseFOOrdSvr_11 >$LOGDIR/log.NseFOOrdSvr_11  2>&1&
fi;

if test "$1 " = "NseFOOrdSvr_12 "; then
        RunProcess NseFOOrdSvr_12 12 NseFOOrdSvr_12 >$LOGDIR/log.NseFOOrdSvr_12  2>&1&
fi;

if test "$1 " = "NseFOOrdSvr_13 "; then
        RunProcess NseFOOrdSvr_13 13 NseFOOrdSvr_13 >$LOGDIR/log.NseFOOrdSvr_13  2>&1&
fi;

if test "$1 " = "NseFOOrdSvr_14 "; then
        RunProcess NseFOOrdSvr_14 14 NseFOOrdSvr_14 >$LOGDIR/log.NseFOOrdSvr_14  2>&1&
fi;

if test "$1 " = "NseFOOrdSvr_15 "; then
        RunProcess NseFOOrdSvr_15 15 NseFOOrdSvr_15 >$LOGDIR/log.NseFOOrdSvr_15  2>&1&
fi;
if test "$1 " = "NseFOOrdSvr_16 "; then
        RunProcess NseFOOrdSvr_16 16 NseFOOrdSvr_16 >$LOGDIR/log.NseFOOrdSvr_16  2>&1&
fi;
if test "$1 " = "NseFOOrdSvr_17 "; then
        RunProcess NseFOOrdSvr_17 17 NseFOOrdSvr_17 >$LOGDIR/log.NseFOOrdSvr_17  2>&1&
fi;
if test "$1 " = "NseFOOrdSvr_18 "; then
        RunProcess NseFOOrdSvr_18 18 NseFOOrdSvr_18 >$LOGDIR/log.NseFOOrdSvr_18  2>&1&
fi;
if test "$1 " = "NseFOOrdSvr_19 "; then
        RunProcess NseFOOrdSvr_19 19 NseFOOrdSvr_19 >$LOGDIR/log.NseFOOrdSvr_19  2>&1&
fi;

if test "$1 " = "NseFOOrdSvr_20 "; then
        RunProcess NseFOOrdSvr_20 20 NseFOOrdSvr_20 >$LOGDIR/log.NseFOOrdSvr_20  2>&1&
fi;

if test "$1 " = "NseFOOrdSvr_21 "; then
        RunProcess NseFOOrdSvr_21 21 NseFOOrdSvr_21 >$LOGDIR/log.NseFOOrdSvr_21  2>&1&
fi;

if test "$1 " = "NseFOOrdSvr_22 "; then
        RunProcess NseFOOrdSvr_22 22 NseFOOrdSvr_22 >$LOGDIR/log.NseFOOrdSvr_22  2>&1&
fi;

if test "$1 " = "NseFOOrdSvr_23 "; then
        RunProcess NseFOOrdSvr_23 23 NseFOOrdSvr_23 >$LOGDIR/log.NseFOOrdSvr_23  2>&1&
fi;

if test "$1 " = "NseFOOrdSvr_24 "; then
        RunProcess NseFOOrdSvr_24 24 NseFOOrdSvr_24 >$LOGDIR/log.NseFOOrdSvr_24  2>&1&
fi;

if test "$1 " = "NseFOOrdSvr_25 "; then
        RunProcess NseFOOrdSvr_25 25 NseFOOrdSvr_25 >$LOGDIR/log.NseFOOrdSvr_25  2>&1&
fi;
if test "$1 " = "NseFOOrdSvr_26 "; then
        RunProcess NseFOOrdSvr_26 26 NseFOOrdSvr_26 >$LOGDIR/log.NseFOOrdSvr_26  2>&1&
fi;
if test "$1 " = "NseFOOrdSvr_27 "; then
        RunProcess NseFOOrdSvr_27 27 NseFOOrdSvr_27 >$LOGDIR/log.NseFOOrdSvr_27  2>&1&
fi;
if test "$1 " = "NseFOOrdSvr_28 "; then
        RunProcess NseFOOrdSvr_28 28 NseFOOrdSvr_28 >$LOGDIR/log.NseFOOrdSvr_28  2>&1&
fi;
if test "$1 " = "NseFOOrdSvr_29 "; then
        RunProcess NseFOOrdSvr_29 29 NseFOOrdSvr_29 >$LOGDIR/log.NseFOOrdSvr_29  2>&1&
fi;

if test "$1 " = "NseFOOrdSvr_30 "; then
        RunProcess NseFOOrdSvr_30 30 NseFOOrdSvr_30 >$LOGDIR/log.NseFOOrdSvr_30  2>&1&
fi;

if test "$1 " = "DRSprdOrdSvr "; then
        RunProcess DRSprdOrdSvr 1 DRSprdOrdSvr >$LOGDIR/log.DRSprdOrdSvr  2>&1&
fi;

if test "$1 " = "NseCDOrdSvr "; then
        RunProcess NseCDOrdSvr 1 NseCDOrdSvr >$LOGDIR/log.NseCDOrdSvr  2>&1&
fi;

if test "$1 " = "NseFOOrdSvrNNF "; then
        RunProcess NseFOOrdSvrNNF 1  NseFOOrdSvrNNF >$LOGDIR/log.NseFOOrdSvrNNF 2>&1&
fi;

if test "$1 " = "DInterface "; then
        RunProcess DInterface $DINTERFACE_PORT  1 D  DInterface >$LOGDIR/log.DInterface  2>&1&
fi;

if test "$1 " = "CInterface "; then
        RunProcess CInterface $CINTERFACE_PORT 2 C CInterface >$LOGDIR/log.CInterface  2>&1&
fi;

if test "$1 " = "CNInterface "; then
        RunProcess CNInterface $CINTERFACE_PORT CNInterface >$LOGDIR/log.CNInterface  2>&1&
fi;

if test "$1 " = "McxCOMExchAdap "; then
        RunProcess McxCOMExchAdap $MCXINTERFACE_PORT 1 M  McxCOMExchAdap >$LOGDIR/log.McxCOMExchAdap  2>&1&
fi;

if test "$1 " = "McxCOMFwdMap_C "; then
        RunProcess McxCOMFwdMap_C $HOME/Application/Exec/ShellScripts/fixSprdconfig.cfg C  McxCOMFwdMap_C >$LOGDIR/log.McxCOMFwdMap_C  2>&1&
fi;

if test "$1 " = "McxCOMFwdMapDrv "; then
        RunProcess McxCOMFwdMapDrv $HOME/Application/Exec/ShellScripts/fixconfig.cfg D  McxCOMFwdMapDrv >$LOGDIR/log.McxCOMFwdMapDrv  2>&1&
fi;

if test "$1 " = "McxCOMFwdMap "; then
        RunProcess McxCOMFwdMap $EXCH_CFG_FILE M  McxCOMFwdMap >$LOGDIR/log.McxCOMFwdMap  2>&1&
fi;

if test "$1 " = "McxCOMFwdMapMcx "; then
        RunProcess McxCOMFwdMapMcx $HOME/Application/Exec/ShellScripts/fixconfig.cfg M  McxCOMFwdMapMcx >$LOGDIR/log.McxCOMFwdMapMcx  2>&1&
fi;

if test "$1 " = "McxCOMRevMapEQ "; then
        RunProcess McxCOMRevMapEQ 9 E McxCOMRevMapEQ >$LOGDIR/log.McxCOMRevMapEQ  2>&1&
fi;

if test "$1 " = "McxCOMRevMapDR "; then
        RunProcess McxCOMRevMapDR 1 D McxCOMRevMapDR >$LOGDIR/log.McxCOMRevMapDR  2>&1&
fi;

if test "$1 " = "ConvToDel "; then
        RunProcess ConvToDel ConvToDel >$LOGDIR/log.ConvToDel 2>&1&
fi;

if test "$1 " = "McxCOMRevMapCD "; then
        RunProcess McxCOMRevMapCD 1 C McxCOMRevMapCD >$LOGDIR/log.McxCOMRevMapCD  2>&1&
fi;

if test "$1 " = "McxCOMRevMapMcx "; then
        RunProcess McxCOMRevMapMcx 1 M McxCOMRevMapMcx >$LOGDIR/log.McxCOMRevMapMcx  2>&1&
fi;

#if test "$1 " = "McxCOMTrdSvr "; then
#        RunProcess McxCOMTrdSvr 1  McxCOMTrdSvr >$LOGDIR/log.McxCOMTrdSvr  2>&1&
#fi;

if test "$1 " = "ENMapTrade "; then
        RunProcess ENMapTrade ENMapTrade >$LOGDIR/log.ENMapTrade 2>&1&
fi;

if test "$1 " = "DNTradeMap "; then
        RunProcess DNTradeMap DNTradeMap >$LOGDIR/log.DNTradeMap 2>&1&
fi;

if test "$1 " = "TradeRouter "; then
        RunProcess TradeRouter TradeRouter >$LOGDIR/log.TradeRouter 2>&1&
fi;

if test "$1 " = "ENBmarkSim "; then
    RunProcess ENBmarkSim  1 1 ENBmarkSim > $LOGDIR/log.ENBmarkSim 2>&1
fi;

if test "$1 " = "Dmarksim "; then
        RunProcess Dmarksim 1 1 Dmarksim > $LOGDIR/log.Dmarksim 2>&1
fi;



if test "$1 " = "RMSRevValidate "; then
        RunProcess RMSRevValidate RMSRevValidate >$LOGDIR/log.RMSRevValidate 2>&1&
fi;

if test "$1 " = "DWSRevMapper "; then
        RunProcess DWSRevMapper DWSRevMapper  >$LOGDIR/log.DWSRevMapper 2>&1&
fi;

if test "$1 " = "DWSMapper "; then
        RunProcess DWSMapper DWSMapper  >$LOGDIR/log.DWSMapper 2>&1&
fi;

if test "$1 " = "CurrBmarkSim "; then
        RunProcess CurrBmarkSim 1 1 CurrBmarkSim > $LOGDIR/log.CurrBmarkSim 2>&1
fi;


if test "$1 " = "ProcessMon "; then
       RunProcess ProcessMon ProcessMon >$LOGDIR/log.ProcessMon 2>&1&
fi;

if test "$1 " = "RupeeDaemon "; then
        RunProcess RupeeDaemon RupeeDaemon >$LOGDIR/log.RupeeDaemon 2>&1&
fi;

if test "$1 " = "D2C1Router "; then
        RunProcess D2C1Router D2C1Router >$LOGDIR/log.D2C1Router 2>&1&
fi;

if test "$1 " = "OfflineOrders "; then
        RunProcess OfflineOrders OfflineOrders >$LOGDIR/log.OfflineOrders 2>&1&
fi;

if test "$1 " = "SIPEquity "; then
        RunProcess SIPEquity SIPEquity >$LOGDIR/log.SIPEquity 2>&1&
fi;

if test "$1 " = "RMSRevVald_1 "; then
        RunProcess RMSRevVald_1 1 RMSRevVald_1 >$LOGDIR/log.RMSRevVald_1 2>&1&
fi;

if test "$1 " = "RMSRevVald_2 "; then
        RunProcess RMSRevVald_2 2 RMSRevVald_2 >$LOGDIR/log.RMSRevVald_2 2>&1&
fi;


if test "$1 " = "RMSRevVald_3 "; then
        RunProcess RMSRevVald_3 3 RMSRevVald_3 >$LOGDIR/log.RMSRevVald_3 2>&1&
fi;

if test "$1 " = "RMSRevVald_4 "; then
        RunProcess RMSRevVald_4 4 RMSRevVald_4 >$LOGDIR/log.RMSRevVald_4 2>&1&
fi;

if test "$1 " = "RMSRevVald_5 "; then
        RunProcess RMSRevVald_5 5 RMSRevVald_5 >$LOGDIR/log.RMSRevVald_5 2>&1
fi;

if test "$1 " = "RMSRevVald_6 "; then
        RunProcess RMSRevVald_6 6 RMSRevVald_6 >$LOGDIR/log.RMSRevVald_6 2>&1
fi;

if test "$1 " = "RMSRevVald_7 "; then
        RunProcess RMSRevVald_7 7 RMSRevVald_7 >$LOGDIR/log.RMSRevVald_7 2>&1
fi;

if test "$1 " = "RMSRevVald_8 "; then
        RunProcess RMSRevVald_8 8 RMSRevVald_8 >$LOGDIR/log.RMSRevVald_8 2>&1
fi;

if test "$1 " = "RMSRevVald_9 "; then
        RunProcess RMSRevVald_9 9 RMSRevVald_9 >$LOGDIR/log.RMSRevVald_9 2>&1
fi;

if test "$1 " = "NEInterface "; then
        RunProcess NEInterface $NEINTERFACE_PORT 1 N NEInterface >$LOGDIR/log.NEInterface 2>&1&
fi;


if test "$1 " = "NseCMTrdSvr_1 "; then
        RunProcess NseCMTrdSvr_1 1 5 3 NseCMTrdSvr_1 >$LOGDIR/log.NseCMTrdSvr_1 2>&1&
fi;


if test "$1 " = "NseCMTrdSvr_2 "; then
        RunProcess NseCMTrdSvr_2 2 5 3 NseCMTrdSvr_2 >$LOGDIR/log.NseCMTrdSvr_2 2>&1&
fi;


if test "$1 " = "NseCMTrdSvr_3 "; then
        RunProcess NseCMTrdSvr_3 3 5 3 NseCMTrdSvr_3 >$LOGDIR/log.NseCMTrdSvr_3 2>&1&
fi;



if test "$1 " = "NseCMTrdSvr_4 "; then
        RunProcess NseCMTrdSvr_4 4 5 3 NseCMTrdSvr_4 >$LOGDIR/log.NseCMTrdSvr_4 2>&1&
fi;

if test "$1 " = "NseCMTrdSvr_5 "; then
        RunProcess NseCMTrdSvr_5 5 5 3 NseCMTrdSvr_5 >$LOGDIR/log.NseCMTrdSvr_5 2>&1&
fi;

if test "$1 " = "NseCMTrdSvr_6 "; then
        RunProcess NseCMTrdSvr_6 6 5 3 NseCMTrdSvr_6 >$LOGDIR/log.NseCMTrdSvr_6 2>&1&
fi;

if test "$1 " = "NseCMTrdSvr_7 "; then
        RunProcess NseCMTrdSvr_7 7 5 3 NseCMTrdSvr_7 >$LOGDIR/log.NseCMTrdSvr_7 2>&1&
fi;

if test "$1 " = "NseCMTrdSvr_8 "; then
        RunProcess NseCMTrdSvr_8 8 5 3 NseCMTrdSvr_8 >$LOGDIR/log.NseCMTrdSvr_8 2>&1&
fi;

if test "$1 " = "NseCMTrdSvr_9 "; then
        RunProcess NseCMTrdSvr_9 9 5 3 NseCMTrdSvr_9 >$LOGDIR/log.NseCMTrdSvr_9 2>&1&
fi;

if test "$1 " = "NseCMTrdSvr_10 "; then
        RunProcess NseCMTrdSvr_10 10 5 3 NseCMTrdSvr_10 >$LOGDIR/log.NseCMTrdSvr_10 2>&1&
fi;

if test "$1 " = "NseCMTrdSvr_11 "; then
        RunProcess NseCMTrdSvr_11 11 5 3 NseCMTrdSvr_11 >$LOGDIR/log.NseCMTrdSvr_11 2>&1&
fi;

if test "$1 " = "NseCMTrdSvr_12 "; then
        RunProcess NseCMTrdSvr_12 12 5 3 NseCMTrdSvr_12 >$LOGDIR/log.NseCMTrdSvr_12 2>&1&
fi;

if test "$1 " = "NseCMTrdSvr_13 "; then
        RunProcess NseCMTrdSvr_13 13 5 3 NseCMTrdSvr_13 >$LOGDIR/log.NseCMTrdSvr_13 2>&1&
fi;

if test "$1 " = "NseCMTrdSvr_14 "; then
        RunProcess NseCMTrdSvr_14 14 5 3 NseCMTrdSvr_14 >$LOGDIR/log.NseCMTrdSvr_14 2>&1&
fi;


if test "$1 " = "NseCMTrdSvr_15 "; then
        RunProcess NseCMTrdSvr_15 15 5 3 NseCMTrdSvr_15 >$LOGDIR/log.NseCMTrdSvr_15 2>&1&
fi;

if test "$1 " = "NseFOTrdSvr_1 "; then
        RunProcess NseFOTrdSvr_1 1 5 3  NseFOTrdSvr_1 >$LOGDIR/log.NseFOTrdSvr_1 2>&1&
fi;

if test "$1 " = "NseFOTrdSvr_2 "; then
        RunProcess NseFOTrdSvr_2 2 5 3 NseFOTrdSvr_2 >$LOGDIR/log.NseFOTrdSvr_2 2>&1&
fi;

if test "$1 " = "NseFOTrdSvr_3 "; then
        RunProcess NseFOTrdSvr_3 3 5 3 NseFOTrdSvr_3 >$LOGDIR/log.NseFOTrdSvr_3 2>&1&
fi;

if test "$1 " = "NseFOTrdSvr_4 "; then
        RunProcess NseFOTrdSvr_4 4 5 3 NseFOTrdSvr_4 >$LOGDIR/log.NseFOTrdSvr_4 2>&1&
fi;

if test "$1 " = "NseFOTrdSvr_5 "; then
        RunProcess NseFOTrdSvr_5 5 5 3 NseFOTrdSvr_5 >$LOGDIR/log.NseFOTrdSvr_5 2>&1&
fi;

if test "$1 " = "NseFOTrdSvr_6 "; then
        RunProcess NseFOTrdSvr_6 6 5 3 NseFOTrdSvr_6 >$LOGDIR/log.NseFOTrdSvr_6 2>&1&
fi;

if test "$1 " = "NseFOTrdSvr_7 "; then
        RunProcess NseFOTrdSvr_7 7 5 3 NseFOTrdSvr_7 >$LOGDIR/log.NseFOTrdSvr_7 2>&1&
fi;

if test "$1 " = "NseFOTrdSvr_8 "; then
        RunProcess NseFOTrdSvr_8 8 5 3 NseFOTrdSvr_8 >$LOGDIR/log.NseFOTrdSvr_8 2>&1&
fi;

if test "$1 " = "NseFOTrdSvr_9 "; then
        RunProcess NseFOTrdSvr_9 9 5 3 NseFOTrdSvr_9 >$LOGDIR/log.NseFOTrdSvr_9 2>&1&
fi;

if test "$1 " = "NseCDTrdSvr "; then
        RunProcess NseCDTrdSvr 1 5 3  NseCDTrdSvr >$LOGDIR/log.NseCDTrdSvr 2>&1&
fi;

if test "$1 " = "NseCDFwdMemMap "; then
        RunProcess NseCDFwdMemMap 1 5 3  NseCDFwdMemMap >$LOGDIR/log.NseCDFwdMemMap 2>&1&
fi;

if test "$1 " = "IntSqrOffBEq "; then
        RunProcess IntSqrOffBEq 1  IntSqrOffBEq >$LOGDIR/log.IntSqrOffBEq 2>&1&
fi;


if test "$1 " = "IntSqrOffNEq "; then
        RunProcess IntSqrOffNEq 2  IntSqrOffNEq >$LOGDIR/log.IntSqrOffNEq 2>&1&
fi;

if test "$1 " = "IntSqrOffNDrv "; then
        RunProcess IntSqrOffNDrv 3  IntSqrOffNDrv >$LOGDIR/log.IntSqrOffNDrv 2>&1&
fi;


if test "$1 " = "IntSqrOffMCom "; then
        RunProcess IntSqrOffMCom 4  IntSqrOffMCom >$LOGDIR/log.IntSqrOffMCom 2>&1&
fi;

if test "$1 " = "IntSqrOffCoMCom "; then
        RunProcess IntSqrOffCoMCom 13  IntSqrOffCoMCom >$LOGDIR/log.IntSqrOffCoMCom 2>&1&
fi;

if test "$1 " = "IntSqrOffBoMCom "; then
	RunProcess IntSqrOffBoMCom 14  IntSqrOffBoMCom >$LOGDIR/log.IntSqrOffBoMCom 2>&1&
fi;

if test "$1 " = "NseCDBcastSptr "; then
        RunProcess NseCDBcastSptr NseCDBcastSptr >$LOGDIR/log.NseCDBcastSptr  2>&1&
fi;

if test "$1 " = "DrvCount "; then
        RunProcess DrvCount DrvCount>$LOGDIR/log.DrvCount 2>&1&
fi;

if test "$1 " = "EqCount "; then
        RunProcess EqCount EqCount>$LOGDIR/log.EqCount 2>&1&
fi;

if test "$1 " = "CurrCount "; then
        RunProcess CurrCount CurrCount>$LOGDIR/log.CurrCount 2>&1&
fi;

if test "$1 " = "McxCOMBcastAdap "; then
        RunProcess McxCOMBcastAdap $MCX_RECV_PORT L B  McxCOMBcastAdap >$LOGDIR/log.McxCOMBcastAdap 2>&1&
fi;

if test "$1 " = "BseCMBcastAdap "; then
        RunProcess BseCMBcastAdap 2363 $BSE_BCAST_RECV_PORT L  EquBseDump.dmp  N EquBse23feb2012.dmp $BEQU_BROADCAST_TYPE BseCMBcastAdap >$LOGDIR/log.BseCMBcastAdap 2>&1&
fi;

if test "$1 " = "BseCMBcastSptr "; then
        RunProcess BseCMBcastSptr  BseCMBcastSptr >$LOGDIR/log.BseCMBcastSptr 2>&1&
fi;

if test "$1 " = "BseCMMbpUpd "; then
        RunProcess BseCMMbpUpd BseCMMbpUpd >$LOGDIR/log.BseCMMbpUpd 2>&1&
fi;

if test "$1 " = "BseCMMktStat "; then
        RunProcess BseCMMktStat BseCMMktStat >$LOGDIR/log.BseCMMktStat 2>&1&
fi;


if test "$1 " = "NseCMRevMap "; then
        RunProcess NseCMRevMap 9  NseCMRevMap >$LOGDIR/log.NseCMRevMap 2>&1&
fi;


if test "$1 " = "NseFORevMap "; then
        RunProcess NseFORevMap 9 NseFORevMap >$LOGDIR/log.NseFORevMap 2>&1&
fi;

if test "$1 " = "NseCDRevMap "; then
        RunProcess NseCDRevMap NseCDRevMap >$LOGDIR/log.NseCDRevMap 2>&1&

fi;

#if test "$1 " = "NseCMExchAdap "; then
#        RunProcess NseCMExchAdap $TAP_EXCH_SIM1 $GROUP_ID $TAP_IP1 $TAP_PORT1 $TAP_FAILOVER_IP1 $TAP_FAILOVER_PORT1 $EQU_CONN_SLEEP_TIME NseCMExchAdap >$LOGDIR/log.NseCMExchAdap 2>&1&
#fi;

if test "$1 " = "NseCMFwdMap "; then
        RunProcess NseCMFwdMap NseCMFwdMap >$LOGDIR/log.NseCMFwdMap 2>&1&
fi;

if test "$1 " = "DNseConAdap "; then
        RunProcess DNseConAdap $DRV_TAP_EXCH_SIM $DRV_TAP_GROUP_ID1 $DRV_TAP_IP $DRV_TAP_PORT $DRV_TAP_FAILOVER_IP $DRV_TAP_FAILOVER_PORT $DRV_CONN_SLEEP_TIME DNseConAdap >$LOGDIR/log.DNseConAdap 2>&1&
fi;

if test "$1 " = "NseFOFwdMap "; then
        RunProcess NseFOFwdMap NseFOFwdMap >$LOGDIR/log.NseFOFwdMap 2>&1&
fi;

#if test "$1 " = "NseCDExchAdap "; then
#        RunProcess NseCDExchAdap $CUR_TAP_EXCH_SIM $GROUP_ID $CUR_TAP_IP $CUR_TAP_PORT $CUR_TAP_FAILOVER_IP $CUR_TAP_FAILOVER_PORT $CURR_CONN_SLEEP_TIME NseCDExchAdap >$LOGDIR/log.NseCDExchAdap 2>&1&
#fi;

if test "$1 " = "NseCDFwdMap "; then
        RunProcess NseCDFwdMap NseCDFwdMap >$LOGDIR/log.NseCDFwdMap 2>&1&
fi;


if test "$1 " = "NseCMCatalyst "; then
        RunProcess NseCMCatalyst $INSTANCE_NSE_EQ NseCMCatalyst >$LOGDIR/log.NseCMCatalyst 2>&1&
fi;

if test "$1 " = "NseCMOrdSvr_1 "; then
        RunProcess NseCMOrdSvr_1 1 NseCMOrdSvr_1> $LOGDIR/log.NseCMOrdSvr_1 2>&1
fi;


if test "$1 " = "NseCMOrdSvr_2 "; then
        RunProcess NseCMOrdSvr_2 2 NseCMOrdSvr_2 >$LOGDIR/log.NseCMOrdSvr_2  2>&1&
fi;

if test "$1 " = "NseCMOrdSvr_3 "; then
        RunProcess NseCMOrdSvr_3 3 NseCMOrdSvr_3 > $LOGDIR/log.NseCMOrdSvr_3 2>&1
fi;

if test "$1 " = "NseCMOrdSvr_4 "; then
        RunProcess NseCMOrdSvr_4 4 NseCMOrdSvr_4 > $LOGDIR/log.NseCMOrdSvr_4 2>&1
fi;

if test "$1 " = "NseCMOrdSvr_5 "; then
        RunProcess NseCMOrdSvr_5 5 NseCMOrdSvr_5 > $LOGDIR/log.NseCMOrdSvr_5 2>&1
fi;

if test "$1 " = "NseCMOrdSvr_6 "; then
        RunProcess NseCMOrdSvr_6 6 NseCMOrdSvr_6 > $LOGDIR/log.NseCMOrdSvr_6 2>&1
fi;

if test "$1 " = "NseCMOrdSvr_7 "; then
        RunProcess NseCMOrdSvr_7 7 NseCMOrdSvr_7 > $LOGDIR/log.NseCMOrdSvr_7 2>&1
fi;

if test "$1 " = "NseCMOrdSvr_8 "; then
        RunProcess NseCMOrdSvr_8 8 NseCMOrdSvr_8 > $LOGDIR/log.NseCMOrdSvr_8 2>&1
fi;

if test "$1 " = "NseCMOrdSvr_9 "; then
        RunProcess NseCMOrdSvr_9 9 NseCMOrdSvr_9 > $LOGDIR/log.NseCMOrdSvr_9 2>&1
fi;

if test "$1 " = "NseCMOrdSvr_10 "; then
        RunProcess NseCMOrdSvr_10 10 NseCMOrdSvr_10 > $LOGDIR/log.NseCMOrdSvr_10 2>&1
fi;

if test "$1 " = "NseCMOrdSvr_11 "; then
        RunProcess NseCMOrdSvr_11 11 NseCMOrdSvr_11 > $LOGDIR/log.NseCMOrdSvr_11 2>&1
fi;

if test "$1 " = "NseCMOrdSvr_12 "; then
        RunProcess NseCMOrdSvr_12 12 NseCMOrdSvr_12 > $LOGDIR/log.NseCMOrdSvr_12 2>&1
fi;


if test "$1 " = "NseCMOrdSvr_13 "; then
        RunProcess NseCMOrdSvr_13 13 NseCMOrdSvr_13 > $LOGDIR/log.NseCMOrdSvr_13 2>&1
fi;

if test "$1 " = "NseCMOrdSvr_14 "; then
        RunProcess NseCMOrdSvr_14 14 NseCMOrdSvr_14 > $LOGDIR/log.NseCMOrdSvr_14 2>&1
fi;

if test "$1 " = "NseCMOrdSvr_15 "; then
        RunProcess NseCMOrdSvr_15 15 NseCMOrdSvr_15 > $LOGDIR/log.NseCMOrdSvr_15 2>&1
fi;

if test "$1 " = "NseCMOrdSvr_16 "; then
        RunProcess NseCMOrdSvr_16 16 NseCMOrdSvr_16 > $LOGDIR/log.NseCMOrdSvr_16 2>&1
fi;

if test "$1 " = "NseCMOrdSvr_17 "; then
        RunProcess NseCMOrdSvr_17 17 NseCMOrdSvr_17 > $LOGDIR/log.NseCMOrdSvr_17 2>&1
fi;

if test "$1 " = "NseCMOrdSvr_18 "; then
        RunProcess NseCMOrdSvr_18 18 NseCMOrdSvr_18 > $LOGDIR/log.NseCMOrdSvr_18 2>&1
fi;

if test "$1 " = "NseCMOrdSvr_19 "; then
        RunProcess NseCMOrdSvr_19 19 NseCMOrdSvr_19 > $LOGDIR/log.NseCMOrdSvr_19 2>&1
fi;

if test "$1 " = "NseCMOrdSvr_20 "; then
        RunProcess NseCMOrdSvr_20 20 NseCMOrdSvr_20 > $LOGDIR/log.NseCMOrdSvr_20 2>&1
fi;

if test "$1 " = "NseCMOrdSvr_21 "; then
        RunProcess NseCMOrdSvr_21 21 NseCMOrdSvr_21 > $LOGDIR/log.NseCMOrdSvr_21 2>&1
fi;

if test "$1 " = "NseCMOrdSvr_22 "; then
        RunProcess NseCMOrdSvr_22 22 NseCMOrdSvr_22 > $LOGDIR/log.NseCMOrdSvr_22 2>&1
fi;

if test "$1 " = "NseCMOrdSvr_23 "; then
        RunProcess NseCMOrdSvr_23 23 NseCMOrdSvr_23 > $LOGDIR/log.NseCMOrdSvr_23 2>&1
fi;

if test "$1 " = "NseCMOrdSvr_24 "; then
        RunProcess NseCMOrdSvr_24 24 NseCMOrdSvr_24 > $LOGDIR/log.NseCMOrdSvr_24 2>&1
fi;

if test "$1 " = "NseCMOrdSvr_25 "; then
        RunProcess NseCMOrdSvr_25 25 NseCMOrdSvr_25 > $LOGDIR/log.NseCMOrdSvr_25 2>&1
fi;

if test "$1 " = "NseCMOrdSvr_26 "; then
        RunProcess NseCMOrdSvr_26 26 NseCMOrdSvr_26 > $LOGDIR/log.NseCMOrdSvr_26 2>&1
fi;

if test "$1 " = "NseCMOrdSvr_27 "; then
        RunProcess NseCMOrdSvr_27 27 NseCMOrdSvr_27 > $LOGDIR/log.NseCMOrdSvr_27 2>&1
fi;

if test "$1 " = "NseCMOrdSvr_28 "; then
        RunProcess NseCMOrdSvr_28 28 NseCMOrdSvr_28 > $LOGDIR/log.NseCMOrdSvr_28 2>&1
fi;

if test "$1 " = "NseCMOrdSvr_29 "; then
        RunProcess NseCMOrdSvr_29 29 NseCMOrdSvr_29 > $LOGDIR/log.NseCMOrdSvr_29 2>&1
fi;

if test "$1 " = "NseCMOrdSvr_30 "; then
        RunProcess NseCMOrdSvr_30 30 NseCMOrdSvr_30 > $LOGDIR/log.NseCMOrdSvr_30 2>&1
fi;



if test "$1 " = "BseCMFwdMap "; then
        RunProcess BseCMFwdMap  BseCMFwdMap >$LOGDIR/log.BseCMFwdMap 2>&1&
fi;

if test "$1 " = "BseCMRevMap "; then
        RunProcess BseCMRevMap 9 BseCMRevMap >$LOGDIR/log.BseCMRevMap 2>&1&
fi;

if test "$1 " = "BseCMTrdSvr_1 "; then
        RunProcess BseCMTrdSvr_1 1 5 3 BseCMTrdSvr_1 >$LOGDIR/log.BseCMTrdSvr_1 2>&1&
fi;

if test "$1 " = "BseCMTrdSvr_2 "; then
        RunProcess BseCMTrdSvr_2 2 5 3 BseCMTrdSvr_2 >$LOGDIR/log.BseCMTrdSvr_2 2>&1&
fi;

if test "$1 " = "BseCMTrdSvr_3 "; then
        RunProcess BseCMTrdSvr_3 3 5 3 BseCMTrdSvr_3 >$LOGDIR/log.BseCMTrdSvr_3 2>&1&
fi;

if test "$1 " = "BseCMTrdSvr_4 "; then
        RunProcess BseCMTrdSvr_4 4 5 3 BseCMTrdSvr_4 >$LOGDIR/log.BseCMTrdSvr_4 2>&1&
fi;

if test "$1 " = "BseCMTrdSvr_5 "; then
        RunProcess BseCMTrdSvr_5 5 5 3 BseCMTrdSvr_5 >$LOGDIR/log.BseCMTrdSvr_5 2>&1&
fi;

if test "$1 " = "BseCMTrdSvr_6 "; then
        RunProcess BseCMTrdSvr_6 6 5 3 BseCMTrdSvr_6 >$LOGDIR/log.BseCMTrdSvr_6 2>&1&
fi;

if test "$1 " = "BseCMTrdSvr_7 "; then
        RunProcess BseCMTrdSvr_7 7 5 3 BseCMTrdSvr_7 >$LOGDIR/log.BseCMTrdSvr_7 2>&1&
fi;

if test "$1 " = "BseCMTrdSvr_8 "; then
        RunProcess BseCMTrdSvr_8 8 5 3 BseCMTrdSvr_8 >$LOGDIR/log.BseCMTrdSvr_8 2>&1&
fi;

if test "$1 " = "BseCMTrdSvr_9 "; then
        RunProcess BseCMTrdSvr_9 9 5 3 BseCMTrdSvr_9 >$LOGDIR/log.BseCMTrdSvr_9 2>&1&
fi;

if test "$1 " = "BseCMTrdSvr_10 "; then
        RunProcess BseCMTrdSvr_10 10 5 3 BseCMTrdSvr_10 >$LOGDIR/log.BseCMTrdSvr_10 2>&1&
fi;

if test "$1 " = "BseCMTrdSvr_11 "; then
        RunProcess BseCMTrdSvr_11 11 5 3 BseCMTrdSvr_11 >$LOGDIR/log.BseCMTrdSvr_11 2>&1&
fi;

if test "$1 " = "BseCMTrdSvr_12 "; then
        RunProcess BseCMTrdSvr_12 12 5 3 BseCMTrdSvr_12 >$LOGDIR/log.BseCMTrdSvr_12 2>&1&
fi;

if test "$1 " = "BseCMTrdSvr_13 "; then
        RunProcess BseCMTrdSvr_13 13 5 3 BseCMTrdSvr_13 >$LOGDIR/log.BseCMTrdSvr_13 2>&1&
fi;

if test "$1 " = "BseCMTrdSvr_14 "; then
        RunProcess BseCMTrdSvr_14 14 5 3 BseCMTrdSvr_14 >$LOGDIR/log.BseCMTrdSvr_14 2>&1&
fi;

if test "$1 " = "BseCMTrdSvr_15 "; then
        RunProcess BseCMTrdSvr_15 15 5 3 BseCMTrdSvr_15 >$LOGDIR/log.BseCMTrdSvr_15 2>&1&
fi;


if test "$1 " = "Connection "; then
        #RunProcess NseCMExchAdap $TAP_EXCH_SIM1 $GROUP_ID $TAP_IP1 $TAP_PORT1 $TAP_FAILOVER_IP1 $TAP_FAILOVER_PORT1 NseCMExchAdap >$LOGDIR/log.NseCMExchAdap 2>&1&
        RunProcess NseCMBoxAdap $TAP_IP1 $TAP_PORT1 $TAP_FAILOVER_IP1 $TAP_FAILOVER_PORT1 $NSE_CM_BOX_PORT $NSE_CM_LOG_ID NseCMBoxAdap >$LOGDIR/log.NseCMBoxAdap 2>&1&
	RunProcess NseCMExchAdap $TAP_EXCH_SIM1 $GROUP_ID $NSE_CM_BOX_IP $NSE_CM_BOX_PORT $NSE_CM_LOG_ID NseCMExchAdap >$LOGDIR/log.NseCMExchAdap 2>&1&
	#RunProcess DNseConAdap $DRV_TAP_EXCH_SIM $DRV_TAP_GROUP_ID1 $DRV_TAP_IP $DRV_TAP_PORT $DRV_TAP_FAILOVER_IP $DRV_TAP_FAILOVER_PORT DNseConAdap >$LOGDIR/log.DNseConAdap 2>&1&
	RunProcess NseFOBoxAdap $DRV_TAP_IP $DRV_TAP_PORT $DRV_TAP_FAILOVER_IP $DRV_TAP_FAILOVER_PORT $DRV_BOX_PORT $DRV_LOG_ID NseFOBoxAdap >$LOGDIR/log.NseFOBoxAdap 2>&1&
	RunProcess NseFOExchAdap $DRV_TAP_EXCH_SIM $GROUP_ID $DRV_BOX_IP $DRV_BOX_PORT $DRV_LOG_ID NseFOExchAdap >$LOGDIR/log.NseFOExchAdap 2>&1&
       	RunProcess NseCDBoxAdap $CUR_TAP_IP $CUR_TAP_PORT $CUR_TAP_FAILOVER_IP $CUR_TAP_FAILOVER_PORT $CUR_BOX_PORT $CUR_LOG_ID NseCDBoxAdap >$LOGDIR/log.NseCDBoxAdap 2>&1&
	RunProcess NseCDExchAdap $CUR_TAP_EXCH_SIM $GROUP_ID $CUR_BOX_IP $CUR_BOX_PORT $CUR_LOG_ID NseCDExchAdap >$LOGDIR/log.NseCDExchAdap 2>&1&
	# RunProcess NseCDExchAdap $CUR_TAP_EXCH_SIM $CUR_TAP_GROUP_ID1 $CUR_TAP_IP $CUR_TAP_PORT $CUR_TAP_FAILOVER_IP $CUR_TAP_FAILOVER_PORT NseCDExchAdap >$LOGDIR/log.NseCDExchAdap 2>&1&
        #RunProcess BseCMExchAdap $GROUP_ID BseCMExchAdap >$LOGDIR/log.BseCMExchAdap 2>&1&
	RunProcess BseCMExchAdap $GROUP_ID $BSE_CM_BOX_IP $BSE_CM_BOX_PORT $BSE_CM_LOG_ID BseCMExchAdap >$LOGDIR/log.BseCMExchAdap 2>&1&
        RunProcess BseFOExchAdap $GROUP_ID $BSE_FO_BOX_IP $BSE_FO_BOX_PORT $BSE_FO_LOG_ID BseFOExchAdap >$LOGDIR/log.BseFOExchAdap 2>&1
        RunProcess McxCOMExchAdap 1 McxCOMExchAdap >$LOGDIR/log.McxCOMExchAdap  2>&1&
fi;

if test "$1 " = "NSEBCAST "; then
        RunProcess NseCMBcastSptr NseCMBcastSptr >$LOGDIR/log.NseCMBcastSptr 2>&1&
        #RunProcess NseCMMbpUpd $MAX_NEQ_MBP_THREAD NseCMMbpUpd >$LOGDIR/log.NseCMMbpUpd 2>&1&
        RunProcess NseCMPubMbpUpd $MAX_NEQ_MBP_THREAD NseCMPubMbpUpd >$LOGDIR/log.NseCMPubMbpUpd 2>&1&
        RunProcess NseCMSubMbpUpd $MAX_NEQ_MBP_THREAD NseCMSubMbpUpd $LOGDIR/log.NseCMSubMbpUpd 2>&1&
        RunProcess NseCMIndxUpldr NseCMIndxUpldr >$LOGDIR/log.NseCMIndxUpldr 2>&1&
        RunProcess NseCMMktStsUpdtr NseCMMktStsUpdtr >$LOGDIR/log.NseCMMktStsUpdtr 2>&1&
fi;


if test "$1 " = "DealerNotify "; then
        RunProcess DealerNotify DealerNotify >$LOGDIR/log.DealerNotify 2>&1&
fi;

if test "$1 " = "NseCMAdapMMap "; then
        RunProcess NseCMAdapMMap NseCMAdapMMap >$LOGDIR/log.NseCMAdapMMap 2>&1&
fi;

if test "$1 " = "ENTrdRtrToRevVal "; then
        RunProcess  ENTrdRtrToRevVal 5 ENTrdRtrToRevVal >$LOGDIR/log.ENTrdRtrToRevVal 2>&1&
fi;

if test "$1 " = "NseCMTrdSvrCB "; then
        RunProcess  NseCMTrdSvrCB NseCMTrdSvrCB >$LOGDIR/log.NseCMTrdSvrCB 2>&1&
fi;

if test "$1 " = "DWSAdaptor_1 "; then
        RunProcess DWSAdaptor_1 $DWS_MAIN_PORT_PRI $DWS_CONNECT_PORT_PRI 0  DWSAdaptor_1 >$LOGDIR/log.DWSAdaptor_1 2>&1&
fi;

if test "$1 " = "DWSAdaptor_2 "; then
        RunProcess DWSAdaptor_2 $DWS_MAIN_PORT_SEC $DWS_CONNECT_PORT_SEC 4  DWSAdaptor_2 >$LOGDIR/log.DWSAdaptor_2 2>&1&
fi;

if test "$1 " = "IntSqrOffCoNEq "; then
        RunProcess IntSqrOffCoNEq 5  IntSqrOffCoNEq >$LOGDIR/log.IntSqrOffCoNEq 2>&1&
fi;

if test "$1 " = "IntSqrOffCoNDr "; then
        RunProcess IntSqrOffCoNDr 6  IntSqrOffCoNDr >$LOGDIR/log.IntSqrOffCoNDr 2>&1&
fi;

if test "$1 " = "IntSqrOffCoNCr "; then
        RunProcess IntSqrOffCoNCr 7  IntSqrOffCoNCr >$LOGDIR/log.IntSqrOffCoNCr 2>&1&
fi;

if test "$1 " = "IntSqrOffCoBEq "; then
        RunProcess IntSqrOffCoBEq 8 IntSqrOffCoBEq >$LOGDIR/log.IntSqrOffCoBEq  2>&1&
fi;

if test "$1 " = "IntSqrOffBoNEq "; then
        RunProcess IntSqrOffBoNEq 9  IntSqrOffBoNEq >$LOGDIR/log.IntSqrOffBoNEq 2>&1&
fi;

if test "$1 " = "IntSqrOffBoNDr "; then
        RunProcess IntSqrOffBoNDr 10 IntSqrOffBoNDr >$LOGDIR/log.IntSqrOffBoNDr 2>&1&
fi;

if test "$1 " = "IntSqrOffBoNCr "; then
        RunProcess IntSqrOffBoNCr 11 IntSqrOffBoNCr >$LOGDIR/log.IntSqrOffBoNCr 2>&1&
fi;

if test "$1 " = "IntSqrOffBoBEq "; then
        RunProcess IntSqrOffBoBEq 12 IntSqrOffBoBEq >$LOGDIR/log.IntSqrOffBoBEq 2>&1&
fi;

if test "$1 " = "IntBulkSqrOff "; then
        RunProcess IntBulkSqrOff 15 IntBulkSqrOff >$LOGDIR/log.IntBulkSqrOff    2>&1&
fi;

if test "$1 " = "AdminQueries_1 "; then
        RunProcess AdminQueries_1 AdminQueries_1 >$LOGDIR/log.AdminQueries_1 2>&1&
fi;

if test "$1 " = "AdminQueries_2 "; then
        RunProcess AdminQueries_2 AdminQueries_2 >$LOGDIR/log.AdminQueries_2 2>&1&
fi;

if test "$1 " = "AdminQueries_3 "; then
        RunProcess AdminQueries_3 AdminQueries_3 >$LOGDIR/log.AdminQueries_3 2>&1&
fi;

if test "$1 " = "AdminAdptr "; then
        RunProcess AdminAdptr $ADMIN_MAIN_PORT_SEC $ADMIN_CONNECT_PORT_SEC 4 AdminAdptr >$LOGDIR/log.AdminAdptr 2>&1&
fi;

if test "$1 " = "AdminUpdInsQry "; then
        RunProcess AdminUpdInsQry AdminUpdInsQry >$LOGDIR/log.AdminUpdInsQry 2>&1&
fi;


if test "$1 " = "NseCMCoPump_1 "; then
        RunProcess NseCMCoPump_1 1 V NseCMCoPump_1 >$LOGDIR/log.NseCMCoPump_1 2>&1&
fi;

if test "$1 " = "NseCMCoPump_2 "; then
        RunProcess NseCMCoPump_2 2 V NseCMCoPump_2 >$LOGDIR/log.NseCMCoPump_2 2>&1&
fi;

if test "$1 " = "NseCMCoPump_3 "; then
        RunProcess NseCMCoPump_3 3  V NseCMCoPump_3 >$LOGDIR/log.NseCMCoPump_3 2>&1&
fi;

if test "$1 " = "NseFOCOPump_1 "; then
        RunProcess NseFOCOPump_1 1  V  NseFOCOPump_1 >$LOGDIR/log.NseFOCOPump_1 2>&1&
fi;

if test "$1 " = "NseFOCOPump_2 "; then
        RunProcess NseFOCOPump_2 2  V  NseFOCOPump_2 >$LOGDIR/log.NseFOCOPump_2 2>&1&
fi;

if test "$1 " = "NseFOBOPump_1 "; then
        RunProcess NseFOBOPump_1 1 B NseFOBOPump_1 >$LOGDIR/log.NseFOBOPump_1 2>&1&
fi;

if test "$1 " = "NseFOBOPump_2 "; then
        RunProcess NseFOBOPump_2 2 B NseFOBOPump_2 >$LOGDIR/log.NseFOBOPump_2 2>&1&
fi;

if test "$1 " = "NseFOBOPump_3 "; then
        RunProcess NseFOBOPump_3 3 B NseFOBOPump_3 >$LOGDIR/log.NseFOBOPump_3 2>&1&
fi;

if test "$1 " = "NseCMBoPump_1 "; then
        RunProcess NseCMBoPump_1 1 B NseCMBoPump_1 >$LOGDIR/log.NseCMBoPump_1 2>&1&
fi;

if test "$1 " = "NseCMBoPump_2 "; then
        RunProcess NseCMBoPump_2 2 B NseCMBoPump_2 >$LOGDIR/log.NseCMBoPump_2 2>&1&
fi;

if test "$1 " = "NseCMBoPump_3 "; then
        RunProcess NseCMBoPump_3 3 B NseCMBoPump_3 >$LOGDIR/log.NseCMBoPump_3 2>&1&
fi;

if test "$1 " = "NseCMBoPump_4 "; then
        RunProcess NseCMBoPump_4 4 B NseCMBoPump_4 >$LOGDIR/log.NseCMBoPump_4 2>&1&
fi;

if test "$1 " = "NseCMBoPump_5 "; then
        RunProcess NseCMBoPump_5 5 B NseCMBoPump_5 >$LOGDIR/log.NseCMBoPump_5 2>&1&
fi;

if test "$1 " = "MarginCaltr "; then
        RunProcess MarginCaltr MarginCaltr >$LOGDIR/log.MarginCaltr 2>&1&
fi;

if test "$1 " = "McxCOBOPump "; then
        RunProcess McxCOBOPump 1 McxCOBOPump >$LOGDIR/log.McxCOBOPump 2>&1&
fi;

if test "$1 " = "McxCOMRevMap "; then
        RunProcess McxCOMRevMap 9 McxCOMRevMap >$LOGDIR/log.McxCOMRevMap 2>&1&
fi;

if test "$1 " = "BCDOrdSvr "; then
        RunProcess BCDOrdSvr 12  BCDOrdSvr >$LOGDIR/log.BCDOrdSvr  2>&1&
fi;

if test "$1 " = "BCDOrderMapper "; then
        RunProcess BCDOrderMapper  BCDOrderMapper >$LOGDIR/log.BCDOrderMapper 2>&1&
fi;

if test "$1 " = "CBseConnect "; then
        RunProcess CBseConnect 1 CBseConnect >$LOGDIR/log.CBseConnect 2>&1&
fi;

if test "$1 " = "EQBOTrailer "; then
        RunProcess EQBOTrailer  E  1 EQBOTrailer >$LOGDIR/log.EQBOTrailer 2>&1&
fi;

if test "$1 " = "AdminTrdRtr "; then
        RunProcess AdminTrdRtr AdminTrdRtr >$LOGDIR/log.AdminTrdRtr 2>&1&
fi;


if test "$1 " = "ENTrdRtToD2C1 "; then
        RunProcess ENTrdRtToD2C1 ENTrdRtToD2C1 >$LOGDIR/log.ENTrdRtToD2C1 2>&1&
fi;

if test "$1 " = "BseCMCOBOPump "; then
        RunProcess BseCMCOBOPump 0 BseCMCOBOPump >$LOGDIR/log.BseCMCOBOPump 2>&1&
fi;

if test "$1 " = "CMOrdSvr_1 "; then
        RunProcess CMOrdSvr_1 1 CMOrdSvr_1 >$LOGDIR/log.CMOrdSvr_1 2>&1&
fi;

if test "$1 " = "CMOrdSvr_2 "; then
        RunProcess CMOrdSvr_2 2 CMOrdSvr_2 >$LOGDIR/log.CMOrdSvr_2 2>&1&
fi;

if test "$1 " = "CMOrderMapper "; then
        RunProcess CMOrderMapper 1 CMOrderMapper >$LOGDIR/log.CMOrderMapper 2>&1&
fi;

if test "$1 " = "NotiFyToFE "; then
        RunProcess NotiFyToFE 1 NotiFyToFE >$LOGDIR/log.NotiFyToFE 2>&1&
fi;

if test "$1 " = "EmarkSim "; then
        RunProcess EmarkSim 1 2 EmarkSim >$LOGDIR/log.EmarkSim 2>&1&
fi;
if test "$1 " = "ComMarkSim "; then
        RunProcess ComMarkSim 1 2 ComMarkSim >$LOGDIR/log.ComMarkSim 2>&1&
fi;

if test "$1 " = "CMCatalyst "; then
        RunProcess CMCatalyst 2 CMCatalyst >$LOGDIR/log.CMCatalyst 2>&1&
fi;

if test "$1 " = "CMTrdSvr_1 "; then
        RunProcess CMTrdSvr_1 1 CMTrdSvr_1 >$LOGDIR/log.CMTrdSvr_1 2>&1&
fi;


if test "$1 " = "CMTrdSvr_2 "; then
        RunProcess CMTrdSvr_2 2 CMTrdSvr_2 >$LOGDIR/log.CMTrdSvr_2 2>&1&
fi;

if test "$1 " = "CMMapTrd "; then
        RunProcess CMMapTrd 2  CMMapTrd >$LOGDIR/log.CMMapTrd 2>&1&
fi;
if test "$1 " = "ENTrdRtToAdmAdp "; then
        RunProcess ENTrdRtToAdmAdp  ENTrdRtToAdmAdp >$LOGDIR/log.ENTrdRtToAdmAdp 2>&1&
fi;

if test "$1 " = "BseCdMapTrd "; then
        RunProcess BseCdMapTrd BseCdMapTrd >$LOGDIR/log.BseCdMapTrd 2>&1&
fi;

if test "$1 " = "BCDTrdSvr "; then
        RunProcess BCDTrdSvr BCDTrdSvr >$LOGDIR/log.BCDTrdSvr 2>&1&
fi;

if test "$1 " = "CurrBsemarkSim "; then
        RunProcess CurrBsemarkSim 1 1 CurrBsemarkSim >$LOGDIR/log.CurrBsemarkSim 2>&1&
fi;


if test "$1 " = "BNseFOOrdSvr "; then
        RunProcess BNseFOOrdSvr 12  BNseFOOrdSvr >$LOGDIR/log.BNseFOOrdSvr  2>&1&
fi;


if test "$1 " = "BDROrderMapper "; then
        RunProcess BDROrderMapper BDROrderMapper >$LOGDIR/log.BDROrderMapper  2>&1&
fi;

if test "$1 " = "BSEDrvmarkSim "; then
        RunProcess BSEDrvmarkSim 1 2 BSEDrvmarkSim >$LOGDIR/log.BSEDrvmarkSim 2>&1&
fi;

if test "$1 " = "BseDrMapTrd "; then
        RunProcess BseDrMapTrd BseDrMapTrd >$LOGDIR/log.BseDrMapTrd 2>&1&
fi;

if test "$1 " = "BNseFOTrdSvr "; then
        RunProcess BNseFOTrdSvr BNseFOTrdSvr >$LOGDIR/log.BNseFOTrdSvr 2>&1&
fi;

if test "$1 " = "MissedTrdMMap "; then
        RunProcess  MissedTrdMMap 1  MissedTrdMMap >$LOGDIR/log.MissedTrdMMap 2>&1&
fi;


if test "$1 " = "NewDWSAdaptor "; then
        RunProcess NewDWSAdaptor $DWS_MAIN_PORT_PRI $DWS_CONNECT_PORT_PRI 1  NewDWSAdaptor >$LOGDIR/log.NewDWSAdaptor 2>&1&
fi;

if test "$1 " = "NseCMLtpUdr "; then
        RunProcess NseCMLtpUdr NseCMLtpUdr >$LOGDIR/log.NseCMLtpUdr 2>&1&
fi;

if test "$1 " = "NseFOLtpUdr "; then
       RunProcess NseFOLtpUdr NseFOLtpUdr >$LOGDIR/log.NseFOLtpUdr 2>&1&
#        RunProcess NseFOLtpUdr NseFOLtpUdr >/dev/null 2>&1&
fi;

if test "$1 " = "NseCDLtpUdr "; then
        RunProcess NseCDLtpUdr NseCDLtpUdr >$LOGDIR/log.NseCDLtpUdr 2>&1&
#        RunProcess NseCDLtpUdr NseCDLtpUdr >/dev/null 2>&1&
fi;

if test "$1 " = "McxCOMLtpUdr "; then
        RunProcess McxCOMLtpUdr McxCOMLtpUdr >$LOGDIR/log.McxCOMLtpUdr 2>&1&
#        RunProcess McxCOMLtpUdr McxCOMLtpUdr >/dev/null 2>&1&
fi;

if test "$1 " = "NseCDBcastAdap "; then
        #RunProcess NseCDBcastAdap  $CURR_MULTICAST_GRP $CURR_MULTICAST_PORT L N NseCDBcastAdap >$LOGDIR/log.NseCDBcastAdap  2>&1&
        RunProcess NseCDBcastAdap  $CURR_MULTICAST_GRP $CURR_MULTICAST_PORT L N $CURR_BROADCAST_TYPE $CURR_RECV_IP NseCDBcastAdap >/dev/null 2>&1&
fi;

if test "$1 " = "NseFOBcastAdap "; then
        RunProcess NseFOBcastAdap $DRV_MULTICAST_GRP $DRV_MULTICAST_PORT L N $DRV_BROADCAST_TYPE $DRV_RECV_IP NseFOBcastAdap >$LOGDIR/log.NseFOBcastAdap 2>&1
fi;

if test "$1 " = "NseCMBcastAdap "; then
        RunProcess NseCMBcastAdap $EQU_MULTICAST_GRP $EQU_MULTICAST_PORT L N $EQU_BROADCAST_TYPE $EQU_RECV_IP NseCMBcastAdap  >$LOGDIR/log.NseCMBcastAdap 2>&1&
fi;

#if test "$1 " = "NseFOExchAdap "; then
#        RunProcess NseFOExchAdap $DRV_TAP_EXCH_SIM $GROUP_ID $DRV_TAP_IP $DRV_TAP_PORT $DRV_TAP_FAILOVER_IP $DRV_TAP_FAILOVER_PORT NseFOExchAdap >$LOGDIR/log.NseFOExchAdap 2>&1&
#fi;

#if test "$1 " = "NseCDExchAdap "; then
#        RunProcess NseCDExchAdap $CUR_TAP_EXCH_SIM $CUR_TAP_GROUP_ID1 $CUR_TAP_IP $CUR_TAP_PORT $CUR_TAP_FAILOVER_IP $CUR_TAP_FAILOVER_PORT NseCDExchAdap >$LOGDIR/log.NseCDExchAdap 2>&1&
#fi;

if test "$1 " = "BseCMExchAdap "; then
        #RunProcess BseCMExchAdap $GROUP_ID BseCMExchAdap >$LOGDIR/log.BseCMExchAdap 2>&1&
	RunProcess BseCMExchAdap $GROUP_ID $BSE_CM_BOX_IP $BSE_CM_BOX_PORT $BSE_CM_LOG_ID BseCMExchAdap >$LOGDIR/log.BseCMExchAdap 2>&1&
fi;

if test "$1 " = "NseCMMktStsUpdtr "; then
        RunProcess NseCMMktStsUpdtr NseCMMktStsUpdtr >$LOGDIR/log.NseCMMktStsUpdtr 2>&1&
fi;

if test "$1 " = "ENTrdRtToDWSAdp "; then
        RunProcess ENTrdRtToDWSAdp ENTrdRtToDWSAdp >$LOGDIR/log.ENTrdRtToDWSAdp 2>&1&
fi;

if test "$1 " = "BseAdapToRevMMap "; then
        RunProcess BseAdapToRevMMap BseAdapToRevMMap >$LOGDIR/log.BseAdapToRevMMap 2>&1&
fi;

if test "$1 " = "BseMMapToAdap "; then
        RunProcess BseMMapToAdap BseMMapToAdap >$LOGDIR/log.BseMMapToAdap 2>&1&
fi;

if test "$1 " = "BseCMOrdSvr_1 "; then
        RunProcess BseCMOrdSvr_1 1 BseCMOrdSvr_1 > $LOGDIR/log.BseCMOrdSvr_1 2>&1
fi;

if test "$1 " = "BseCMOrdSvr_2 "; then
        RunProcess BseCMOrdSvr_2 2 BseCMOrdSvr_2 > $LOGDIR/log.BseCMOrdSvr_2 2>&1
fi;

if test "$1 " = "BseCMOrdSvr_3 "; then
        RunProcess BseCMOrdSvr_3 3 BseCMOrdSvr_3 > $LOGDIR/log.BseCMOrdSvr_3 2>&1
fi;

if test "$1 " = "BseCMOrdSvr_4 "; then
        RunProcess BseCMOrdSvr_4 4 BseCMOrdSvr_4 > $LOGDIR/log.BseCMOrdSvr_4 2>&1
fi;

if test "$1 " = "BseCMOrdSvr_5 "; then
        RunProcess BseCMOrdSvr_5 5 BseCMOrdSvr_5 > $LOGDIR/log.BseCMOrdSvr_5 2>&1
fi;

if test "$1 " = "BseCMOrdSvr_6 "; then
        RunProcess BseCMOrdSvr_6 6 BseCMOrdSvr_6 > $LOGDIR/log.BseCMOrdSvr_6 2>&1
fi;

if test "$1 " = "BseCMOrdSvr_7 "; then
        RunProcess BseCMOrdSvr_7 7 BseCMOrdSvr_7 > $LOGDIR/log.BseCMOrdSvr_7 2>&1
fi;

if test "$1 " = "BseCMOrdSvr_8 "; then
        RunProcess BseCMOrdSvr_8 8 BseCMOrdSvr_8 > $LOGDIR/log.BseCMOrdSvr_8 2>&1
fi;

if test "$1 " = "BseCMOrdSvr_9 "; then
        RunProcess BseCMOrdSvr_9 9 BseCMOrdSvr_9 > $LOGDIR/log.BseCMOrdSvr_9 2>&1
fi;

if test "$1 " = "BseCMOrdSvr_10 "; then
        RunProcess BseCMOrdSvr_10 10 BseCMOrdSvr_10 > $LOGDIR/log.BseCMOrdSvr_10 2>&1
fi;

if test "$1 " = "BseCMOrdSvr_11 "; then
        RunProcess BseCMOrdSvr_11 11 BseCMOrdSvr_11 > $LOGDIR/log.BseCMOrdSvr_11 2>&1
fi;

if test "$1 " = "BseCMOrdSvr_12 "; then
        RunProcess BseCMOrdSvr_12 12 BseCMOrdSvr_12 > $LOGDIR/log.BseCMOrdSvr_12 2>&1
fi;

if test "$1 " = "BseCMOrdSvr_13 "; then
        RunProcess BseCMOrdSvr_13 13 BseCMOrdSvr_13 > $LOGDIR/log.BseCMOrdSvr_13 2>&1
fi;

if test "$1 " = "BseCMOrdSvr_14 "; then
        RunProcess BseCMOrdSvr_14 14 BseCMOrdSvr_14 > $LOGDIR/log.BseCMOrdSvr_14 2>&1
fi;

if test "$1 " = "BseCMOrdSvr_15 "; then
        RunProcess BseCMOrdSvr_15 15 BseCMOrdSvr_15 > $LOGDIR/log.BseCMOrdSvr_15 2>&1
fi;

if test "$1 " = "BseCMOrdSvr_16 "; then
        RunProcess BseCMOrdSvr_16 16 BseCMOrdSvr_16 > $LOGDIR/log.BseCMOrdSvr_16 2>&1
fi;

if test "$1 " = "BseCMOrdSvr_17 "; then
        RunProcess BseCMOrdSvr_17 17 BseCMOrdSvr_17 > $LOGDIR/log.BseCMOrdSvr_17 2>&1
fi;

if test "$1 " = "BseCMOrdSvr_18 "; then
        RunProcess BseCMOrdSvr_18 18 BseCMOrdSvr_18 > $LOGDIR/log.BseCMOrdSvr_18 2>&1
fi;

if test "$1 " = "BseCMOrdSvr_19 "; then
        RunProcess BseCMOrdSvr_19 19 BseCMOrdSvr_19 > $LOGDIR/log.BseCMOrdSvr_19 2>&1
fi;

if test "$1 " = "BseCMOrdSvr_20 "; then
        RunProcess BseCMOrdSvr_20 20 BseCMOrdSvr_20 > $LOGDIR/log.BseCMOrdSvr_20 2>&1
fi;

if test "$1 " = "BseCMOrdSvr_21 "; then
        RunProcess BseCMOrdSvr_21 21 BseCMOrdSvr_21 > $LOGDIR/log.BseCMOrdSvr_21 2>&1
fi;

if test "$1 " = "BseCMOrdSvr_22 "; then
        RunProcess BseCMOrdSvr_22 22 BseCMOrdSvr_22 > $LOGDIR/log.BseCMOrdSvr_22 2>&1
fi;

if test "$1 " = "BseCMOrdSvr_23 "; then
        RunProcess BseCMOrdSvr_23 23 BseCMOrdSvr_23 > $LOGDIR/log.BseCMOrdSvr_23 2>&1
fi;

if test "$1 " = "BseCMOrdSvr_24 "; then
        RunProcess BseCMOrdSvr_24 24 BseCMOrdSvr_24 > $LOGDIR/log.BseCMOrdSvr_24 2>&1
fi;

if test "$1 " = "BseCMOrdSvr_25 "; then
        RunProcess BseCMOrdSvr_25 25 BseCMOrdSvr_25 > $LOGDIR/log.BseCMOrdSvr_25 2>&1
fi;

if test "$1 " = "BseCMOrdSvr_26 "; then
        RunProcess BseCMOrdSvr_26 26 BseCMOrdSvr_26 > $LOGDIR/log.BseCMOrdSvr_26 2>&1
fi;

if test "$1 " = "BseCMOrdSvr_27 "; then
        RunProcess BseCMOrdSvr_27 27 BseCMOrdSvr_27 > $LOGDIR/log.BseCMOrdSvr_27 2>&1
fi;

if test "$1 " = "BseCMOrdSvr_28 "; then
        RunProcess BseCMOrdSvr_28 28 BseCMOrdSvr_28 > $LOGDIR/log.BseCMOrdSvr_28 2>&1
fi;

if test "$1 " = "BseCMOrdSvr_29 "; then
        RunProcess BseCMOrdSvr_29 29 BseCMOrdSvr_29 > $LOGDIR/log.BseCMOrdSvr_29 2>&1
fi;

if test "$1 " = "BseCMOrdSvr_30 "; then
        RunProcess BseCMOrdSvr_30 30 BseCMOrdSvr_30 > $LOGDIR/log.BseCMOrdSvr_30 2>&1
fi;

if test "$1 " = "BseCMCatalyst "; then
        RunProcess BseCMCatalyst $INSTANCE_BSE_EQ BseCMCatalyst >$LOGDIR/log.BseCMCatalyst 2>&1&
fi;


if test "$1 " = "MTMChecker "; then
        RunProcess MTMChecker MTMChecker >$LOGDIR/log.MTMChecker 2>&1&
fi;

if test "$1 " = "MTMOrdCanclPumper "; then
        RunProcess MTMOrdCanclPumper MTMOrdCanclPumper >$LOGDIR/log.MTMOrdCanclPumper 2>&1&
fi;

if test "$1 " = "NseCMBToSptrMM "; then
        RunProcess NseCMBToSptrMM NseCMBToSptrMM >$LOGDIR/log.NseCMBToSptrMM 2>&1&
fi;

if test "$1 " = "NseCMSptrToMbpMM "; then
        RunProcess NseCMSptrToMbpMM NseCMSptrToMbpMM >$LOGDIR/log.NseCMSptrToMbpMM 2>&1&
fi;
if test "$1 " = "NseCMPubMbpUpd "; then
#       RunProcess NseCMPubMbpUpd $MAX_NEQ_MBP_THREAD NseCMPubMbpUpd >$LOGDIR/log.NseCMPubMbpUpd 2>&1&
         RunProcess NseCMPubMbpUpd $MAX_NEQ_MBP_THREAD NseCMPubMbpUpd >$LOGDIR/log.NseCMPubMbpUpd 2>&1&
fi;

if test "$1 " = "NseCMSubMbpUpd "; then
        RunProcess NseCMSubMbpUpd $MAX_NEQ_MBP_THREAD NseCMSubMbpUpd >$LOGDIR/log.NseCMSubMbpUpd 2>&1&
#        RunProcess NseCMSubMbpUpd $MAX_NEQ_MBP_THREAD NseCMSubMbpUpd >/dev/null 2>&1&
fi;

if test "$1 " = "BseCMPubMbpUpd "; then
        RunProcess BseCMPubMbpUpd $MAX_NEQ_MBP_THREAD BseCMPubMbpUpd >$LOGDIR/log.BseCMPubMbpUpd 2>&1&
fi;

if test "$1 " = "BseCMSubMbpUpd "; then
        RunProcess BseCMSubMbpUpd $MAX_NEQ_MBP_THREAD BseCMSubMbpUpd >$LOGDIR/log.BseCMSubMbpUpd 2>&1&
fi;

if test "$1 " = "NseFOPubMbpUpd "; then
        RunProcess NseFOPubMbpUpd $MAX_NEQ_MBP_THREAD 1 NseFOPubMbpUpd >$LOGDIR/log.NseFOPubMbpUpd 2>&1&
fi;

if test "$1 " = "NseFOSubMbpUpd "; then
        RunProcess NseFOSubMbpUpd $MAX_NEQ_MBP_THREAD NseFOSubMbpUpd >$LOGDIR/log.NseFOSubMbpUpd 2>&1&
fi;

if test "$1 " = "NseCMFwdMemMap "; then
        RunProcess NseCMFwdMemMap NseCMFwdMemMap >$LOGDIR/log.NseCMFwdMemMap 2>&1&
fi;


if test "$1 " = "NseCMExchSim "; then
    RunProcess NseCMExchSim $GROUP_ID 1 NseCMExchSim > $LOGDIR/log.NseCMExchSim 2>&1
fi;

if test "$1 " = "BseCMmarkSim "; then
        RunProcess BseCMmarkSim $GROUP_ID 15 20 9 Y 5 BseCMmarkSim >$LOGDIR/log.BseCMmarkSim 2>&1&
fi;

if test "$1 " = "McxCOMmarkSim "; then
        RunProcess McxCOMmarkSim $GROUP_ID 10 9 Y McxCOMmarkSim >$LOGDIR/log.McxCOMmarkSim 2>&1&
fi;


if test "$1 " = "NseCMmarkSim "; then
        RunProcess NseCMmarkSim $GROUP_ID 10 20 9 10 NseCMmarkSim >$LOGDIR/log.NseCMmarkSim 2>&1&
fi;

if test "$1 " = "CltDmonToOrdRtrMMap "; then
        RunProcess CltDmonToOrdRtrMMap CltDmonToOrdRtrMMap >$LOGDIR/log.CltDmonToOrdRtrMMap 2>&1&
fi;

if test "$1 " = "BulkOrdToDmonMMap "; then
        RunProcess BulkOrdToDmonMMap BulkOrdToDmonMMap >$LOGDIR/log.BulkOrdToDmonMMap 2>&1&
fi;

if test "$1 " = "ServerDaemon "; then
        RunProcess ServerDaemon $AUTO_DAEMON_PORT ServerDaemon >$LOGDIR/log.ServerDaemon 2>&1&
fi;

if test "$1 " = "ClientDaemon "; then
        RunProcess ClientDaemon $AUTO_DAEMON_PORT $AUTO_DAEMON_IP ClientDaemon >$LOGDIR/log.ClientDaemon 2>&1&
fi;

if test "$1 " = "NotiFyToFE_1 "; then
        RunProcess NotiFyToFE_1 1 NotiFyToFE_1 >$LOGDIR/log.NotiFyToFE_1 2>&1&
fi;

if test "$1 " = "NotiFyToFE_2 "; then
        RunProcess NotiFyToFE_2 2 NotiFyToFE_2 >$LOGDIR/log.NotiFyToFE_2 2>&1&
fi;

if test "$1 " = "NotiFyToFE_3 "; then
        RunProcess NotiFyToFE_3 3 NotiFyToFE_3 >$LOGDIR/log.NotiFyToFE_3 2>&1&
fi;

if test "$1 " = "NotiFyToFE_4 "; then
        RunProcess NotiFyToFE_4 4 NotiFyToFE_4 >$LOGDIR/log.NotiFyToFE_4 2>&1&
fi;

if test "$1 " = "NotiFyToFE_5 "; then
        RunProcess NotiFyToFE_5 5 NotiFyToFE_5 >$LOGDIR/log.NotiFyToFE_5 2>&1&
fi;
if test "$1 " = "NotifyMMapToCatalyst "; then
        RunProcess NotifyMMapToCatalyst 5 NotifyMMapToCatalyst >$LOGDIR/log.NotifyMMapToCatalyst 2>&1&
fi;

if test "$1 " = "MarketDaemon "; then
        RunProcess MarketDaemon MarketDaemon >$LOGDIR/log.MarketDaemon 2>&1&
fi;

if test "$1 " = "ClientNotifyFE "; then
        RunProcess ClientNotifyFE ClientNotifyFE >$LOGDIR/log.ClientNotifyFE 2>&1&
fi;

if test "$1 " = "CKTChecker "; then
        RunProcess CKTChecker CKTChecker >$LOGDIR/log.CKTChecker 2>&1&
fi;

if test "$1 " = "CKTOrdCanclPumper "; then
        RunProcess CKTOrdCanclPumper CKTOrdCanclPumper >$LOGDIR/log.CKTOrdCanclPumper 2>&1&
fi;


if test "$1 " = "NseFOPubMbpUpd "; then
        RunProcess NseFOPubMbpUpd $MAX_NEQ_MBP_THREAD 1 NseFOPubMbpUpd >$LOGDIR/log.NseFOPubMbpUpd 2>&1&
fi;

if test "$1 " = "NseFOSubMbpUpd "; then
        RunProcess NseFOSubMbpUpd $MAX_NEQ_MBP_THREAD NseFOSubMbpUpd >$LOGDIR/log.NseFOSubMbpUpd 2>&1&
fi;

if test "$1 " = "NseFOFwdMemMap "; then
        RunProcess NseFOFwdMemMap NseFOFwdMemMap >$LOGDIR/log.NseFOFwdMemMap 2>&1&
fi;

if test "$1 " = "NseFOmarkSim "; then
        RunProcess NseFOmarkSim $GROUP_ID 10 1000 5 100 NseFOmarkSim >$LOGDIR/log.NseFOmarkSim 2>&1&
fi;

if test "$1 " = "GTTOrders "; then
        RunProcess GTTOrders GTTOrders >$LOGDIR/log.GTTOrders 2>&1&
fi;

if test "$1 " = "GTTBrdcstProcess "; then
        RunProcess GTTBrdcstProcess 1 GTTBrdcstProcess >$LOGDIR/log.GTTBrdcstProcess 2>&1&
fi;

if test "$1 " = "NseCDSAddMktStsUpd "; then
        RunProcess NseCDSAddMktStsUpd 1  NseCDSAddMktStsUpd >$LOGDIR/log.NseCDSAddMktStsUpd 2>&1&
fi;

if test "$1 " = "NseFOSAddDPRUpd "; then
        RunProcess NseFOSAddDPRUpd 1  NseFOSAddDPRUpd >$LOGDIR/log.NseFOSAddDPRUpd 2>&1&
fi;

if test "$1 " = "NseCDSAddDPRUpd "; then
        RunProcess NseCDSAddDPRUpd 1  NseCDSAddDPRUpd >$LOGDIR/log.NseCDSAddDPRUpd 2>&1&
fi;

if test "$1 " = "NseCDSMemDPRUpd "; then
        RunProcess NseCDSMemDPRUpd 1 5 NseCDSMemDPRUpd >$LOGDIR/log.NseCDSMemDPRUpd 2>&1&
fi;

if test "$1 " = "NseFOSMemDPRUpd "; then
        RunProcess NseFOSMemDPRUpd 1 1 NseFOSMemDPRUpd >$LOGDIR/log.NseFOSMemDPRUpd 2>&1&
fi;


if test "$1 " = "NseFOSAddMbpUpd "; then
        RunProcess NseFOSAddMbpUpd $MAX_NEQ_MBP_THREAD 1 NseFOSAddMbpUpd >$LOGDIR/log.NseFOSAddMbpUpd 2>&1&
fi;

if test "$1 " = "NseFOSMemMbpUpd "; then
        RunProcess NseFOSMemMbpUpd 1 1 NseFOSMemMbpUpd >$LOGDIR/log.NseFOSMemMbpUpd 2>&1&
fi;

if test "$1 " = "BseCMRevMemMap_1 "; then
        RunProcess BseCMRevMemMap_1 1  BseCMRevMemMap_1 >$LOGDIR/log.BseCMRevMemMap_1 2>&1&
fi;

if test "$1 " = "BseCMRevMemMap_2 "; then
        RunProcess BseCMRevMemMap_2 2  BseCMRevMemMap_2 >$LOGDIR/log.BseCMRevMemMap_2 2>&1&
fi;

if test "$1 " = "BseCMRevMemMap_3 "; then
        RunProcess BseCMRevMemMap_3 3  BseCMRevMemMap_3 >$LOGDIR/log.BseCMRevMemMap_3 2>&1&
fi;
if test "$1 " = "BseCMRevMemMap_4 "; then
        RunProcess BseCMRevMemMap_4 4  BseCMRevMemMap_4 >$LOGDIR/log.BseCMRevMemMap_4 2>&1&
fi;

if test "$1 " = "BseCMRevMemMap_5 "; then
        RunProcess BseCMRevMemMap_5 5  BseCMRevMemMap_5 >$LOGDIR/log.BseCMRevMemMap_5 2>&1&
fi;

if test "$1 " = "BseCMRevMemMap_6 "; then
        RunProcess BseCMRevMemMap_6 6  BseCMRevMemMap_6 >$LOGDIR/log.BseCMRevMemMap_6 2>&1&
fi;

if test "$1 " = "BseCMRevMemMap_7 "; then
        RunProcess BseCMRevMemMap_7 7  BseCMRevMemMap_7 >$LOGDIR/log.BseCMRevMemMap_7 2>&1&
fi;

if test "$1 " = "BseCMRevMemMap_8 "; then
        RunProcess BseCMRevMemMap_8 8  BseCMRevMemMap_8 >$LOGDIR/log.BseCMRevMemMap_8 2>&1&
fi;

if test "$1 " = "BseCMRevMemMap_9 "; then
        RunProcess BseCMRevMemMap_9 9  BseCMRevMemMap_9 >$LOGDIR/log.BseCMRevMemMap_9 2>&1&
fi;

if test "$1 " = "BseCMFwdMemMap "; then
        RunProcess BseCMFwdMemMap BseCMFwdMemMap >$LOGDIR/log.BseCMFwdMemMap 2>&1&
fi;

if test "$1 " = "PNLSpanDaemon "; then
        RunProcess PNLSpanDaemon 5  PNLSpanDaemon >$LOGDIR/log.PNLSpanDaemon 2>&1&
fi;

if test "$1 " = "NseCDSAddMbpUpd "; then
         RunProcess NseCDSAddMbpUpd $MAX_NEQ_MBP_THREAD 1 NseCDSAddMbpUpd >$LOGDIR/log.NseCDSAddMbpUpd 2>&1&
fi;

if test "$1 " = "NseCDSMemMbpUpd "; then
        RunProcess NseCDSMemMbpUpd $MAX_NEQ_MBP_THREAD 1 NseCDSMemMbpUpd >$LOGDIR/log.NseCDSMemMbpUpd 2>&1&
fi;

if test "$1 " = "NseCDPubMbpUpd "; then
         RunProcess NseCDPubMbpUpd $MAX_NEQ_MBP_THREAD 1 NseCDPubMbpUpd >$LOGDIR/log.NseCDPubMbpUpd 2>&1&
fi;

if test "$1 " = "NseCDSubMbpUpd "; then
        RunProcess NseCDSubMbpUpd $MAX_NEQ_MBP_THREAD 1 NseCDSubMbpUpd >$LOGDIR/log.NseCDSubMbpUpd 2>&1&
fi;

if test "$1 " = "McxCOMSAddMbpUpd "; then
        RunProcess McxCOMSAddMbpUpd $MAX_NEQ_MBP_THREAD McxCOMSAddMbpUpd >$LOGDIR/log.McxCOMSAddMbpUpd 2>&1&
fi;

if test "$1 " = "McxCOMSMemMbpUpd "; then
        RunProcess McxCOMSMemMbpUpd $MAX_NEQ_MBP_THREAD McxCOMSMemMbpUpd >$LOGDIR/log.McxCOMSMemMbpUpd 2>&1&
fi;

if test "$1 " = "BseCMSAddMbpUpd "; then
        RunProcess BseCMSAddMbpUpd $MAX_NEQ_MBP_THREAD 1  BseCMSAddMbpUpd >$LOGDIR/log.BseCMSAddMbpUpd 2>&1&
fi;

if test "$1 " = "BseCMSMemMbpUpd "; then
        RunProcess BseCMSMemMbpUpd $MAX_NEQ_MBP_THREAD 1  BseCMSMemMbpUpd >$LOGDIR/log.BseCMSMemMbpUpd 2>&1&
fi;

if test "$1 " = "NseFOSAddDPRUpd "; then
        RunProcess NseFOSAddDPRUpd 1  NseFOSAddDPRUpd >$LOGDIR/log.NseFOSAddDPRUpd 2>&1&
fi;

if test "$1 " = "NseCMSAddMbpUpd "; then
        RunProcess NseCMSAddMbpUpd 1 1 NseCMSAddMbpUpd >$LOGDIR/log.NseCMSAddMbpUpd 2>&1&
fi;

if test "$1 " = "NseCMSMemMbpUpd "; then
        RunProcess NseCMSMemMbpUpd $MAX_NEQ_MBP_THREAD 1 NseCMSMemMbpUpd >$LOGDIR/log.NseCMSMemMbpUpd 2>&1&
fi;

if test "$1 " = "NseCMMktStsAdap "; then
        RunProcess NseCMMktStsAdap $EQU_MULTICAST_GRP $EQU_MULTICAST_PORT L N $EQU_BROADCAST_TYPE $EQU_RECV_IP NseCMMktStsAdap >$LOGDIR/log.NseCMMktStsAdap 2>&1&
fi;

if test "$1 " = "NseCMSMemMktStsUpd "; then
        RunProcess NseCMSMemMktStsUpd 1 1 NseCMSMemMktStsUpd >$LOGDIR/log.NseCMSMemMktStsUpd 2>&1&
fi;

if test "$1 " = "NseCMSAddMktStsUpd "; then
        RunProcess NseCMSAddMktStsUpd 1  NseCMSAddMktStsUpd >$LOGDIR/log.NseCMSAddMktStsUpd 2>&1&
fi;


if test "$1 " = "NseCDCatalyst "; then
        RunProcess NseCDCatalyst $INSTANCE_NSE_CD NseCDCatalyst >$LOGDIR/log.NseCDCatalyst 2>&1&
fi;

if test "$1 " = "NseCDOrdSvr_1 "; then
        RunProcess NseCDOrdSvr_1 1 NseCDOrdSvr_1 >$LOGDIR/log.NseCDOrdSvr_1  2>&1&
fi;

if test "$1 " = "NseCDOrdSvr_2 "; then
        RunProcess NseCDOrdSvr_2 2 NseCDOrdSvr_2 >$LOGDIR/log.NseCDOrdSvr_2  2>&1&
fi;

if test "$1 " = "NseCDOrdSvr_3 "; then
        RunProcess NseCDOrdSvr_3 3 NseCDOrdSvr_3 >$LOGDIR/log.NseCDOrdSvr_3  2>&1&
fi;

if test "$1 " = "NseCDOrdSvr_4 "; then
        RunProcess NseCDOrdSvr_4 4 NseCDOrdSvr_4 >$LOGDIR/log.NseCDOrdSvr_4  2>&1&
fi;

if test "$1 " = "NseCDOrdSvr_5 "; then
        RunProcess NseCDOrdSvr_5 5 NseCDOrdSvr_5 >$LOGDIR/log.NseCDOrdSvr_5  2>&1&
fi;

if test "$1 " = "NseCDOrdSvr_6 "; then
        RunProcess NseCDOrdSvr_6 6 NseCDOrdSvr_6 >$LOGDIR/log.NseCDOrdSvr_6  2>&1&
fi;

if test "$1 " = "NseCDOrdSvr_7 "; then
        RunProcess NseCDOrdSvr_7 7 NseCDOrdSvr_7 >$LOGDIR/log.NseCDOrdSvr_7  2>&1&
fi;

if test "$1 " = "NseCDOrdSvr_8 "; then
        RunProcess NseCDOrdSvr_8 8 NseCDOrdSvr_8 >$LOGDIR/log.NseCDOrdSvr_8  2>&1&
fi;

if test "$1 " = "NseCDOrdSvr_9 "; then
        RunProcess NseCDOrdSvr_9 9 NseCDOrdSvr_9 >$LOGDIR/log.NseCDOrdSvr_9  2>&1&
fi;

if test "$1 " = "NseCDOrdSvr_10 "; then
        RunProcess NseCDOrdSvr_10 10 NseCDOrdSvr_10 > $LOGDIR/log.NseCDOrdSvr_10 2>&1
fi;

if test "$1 " = "NseCDOrdSvr_11 "; then
        RunProcess NseCDOrdSvr_11 11 NseCDOrdSvr_11 > $LOGDIR/log.NseCDOrdSvr_11 2>&1
fi;

if test "$1 " = "NseCDOrdSvr_12 "; then
        RunProcess NseCDOrdSvr_12 12 NseCDOrdSvr_12 > $LOGDIR/log.NseCDOrdSvr_12 2>&1
fi;


if test "$1 " = "NseCDOrdSvr_13 "; then
        RunProcess NseCDOrdSvr_13 13 NseCDOrdSvr_13 > $LOGDIR/log.NseCDOrdSvr_13 2>&1
fi;

if test "$1 " = "NseCDOrdSvr_14 "; then
        RunProcess NseCDOrdSvr_14 14 NseCDOrdSvr_14 > $LOGDIR/log.NseCDOrdSvr_14 2>&1
fi;

if test "$1 " = "NseCDOrdSvr_15 "; then
        RunProcess NseCDOrdSvr_15 15 NseCDOrdSvr_15 > $LOGDIR/log.NseCDOrdSvr_15 2>&1
fi;

if test "$1 " = "NseCDOrdSvr_16 "; then
        RunProcess NseCDOrdSvr_16 16 NseCDOrdSvr_16 > $LOGDIR/log.NseCDOrdSvr_16 2>&1
fi;

if test "$1 " = "NseCDOrdSvr_17 "; then
        RunProcess NseCDOrdSvr_17 17 NseCDOrdSvr_17 > $LOGDIR/log.NseCDOrdSvr_17 2>&1
fi;

if test "$1 " = "NseCDOrdSvr_18 "; then
        RunProcess NseCDOrdSvr_18 18 NseCDOrdSvr_18 > $LOGDIR/log.NseCDOrdSvr_18 2>&1
fi;

if test "$1 " = "NseCDOrdSvr_19 "; then
        RunProcess NseCDOrdSvr_19 19 NseCDOrdSvr_19 > $LOGDIR/log.NseCDOrdSvr_19 2>&1
fi;

if test "$1 " = "NseCDOrdSvr_20 "; then
        RunProcess NseCDOrdSvr_20 20 NseCDOrdSvr_20 > $LOGDIR/log.NseCDOrdSvr_20 2>&1
fi;

if test "$1 " = "NseCDOrdSvr_21 "; then
        RunProcess NseCDOrdSvr_21 21 NseCDOrdSvr_21 > $LOGDIR/log.NseCDOrdSvr_21 2>&1
fi;

if test "$1 " = "NseCDOrdSvr_22 "; then
        RunProcess NseCDOrdSvr_22 22 NseCDOrdSvr_22 > $LOGDIR/log.NseCDOrdSvr_22 2>&1
fi;

if test "$1 " = "NseCDOrdSvr_23 "; then
        RunProcess NseCDOrdSvr_23 23 NseCDOrdSvr_23 > $LOGDIR/log.NseCDOrdSvr_23 2>&1
fi;

if test "$1 " = "NseCDOrdSvr_24 "; then
        RunProcess NseCDOrdSvr_24 24 NseCDOrdSvr_24 > $LOGDIR/log.NseCDOrdSvr_24 2>&1
fi;

if test "$1 " = "NseCDOrdSvr_25 "; then
        RunProcess NseCDOrdSvr_25 25 NseCDOrdSvr_25 > $LOGDIR/log.NseCDOrdSvr_25 2>&1
fi;

if test "$1 " = "NseCDOrdSvr_26 "; then
        RunProcess NseCDOrdSvr_26 26 NseCDOrdSvr_26 > $LOGDIR/log.NseCDOrdSvr_26 2>&1
fi;

if test "$1 " = "NseCDOrdSvr_27 "; then
        RunProcess NseCDOrdSvr_27 27 NseCDOrdSvr_27 > $LOGDIR/log.NseCDOrdSvr_27 2>&1
fi;

if test "$1 " = "NseCDOrdSvr_28 "; then
        RunProcess NseCDOrdSvr_28 28 NseCDOrdSvr_28 > $LOGDIR/log.NseCDOrdSvr_28 2>&1
fi;

if test "$1 " = "NseCDOrdSvr_29 "; then
        RunProcess NseCDOrdSvr_29 29 NseCDOrdSvr_29 > $LOGDIR/log.NseCDOrdSvr_29 2>&1
fi;

if test "$1 " = "NseCDOrdSvr_30 "; then
        RunProcess NseCDOrdSvr_30 30 NseCDOrdSvr_30 > $LOGDIR/log.NseCDOrdSvr_30 2>&1
fi;


if test "$1 " = "NseCDTrdSvr_1 "; then
        RunProcess NseCDTrdSvr_1 1 5 3  NseCDTrdSvr_1 >$LOGDIR/log.NseCDTrdSvr_1 2>&1&
fi;

if test "$1 " = "NseCDTrdSvr_2 "; then
        RunProcess NseCDTrdSvr_2 2 5 3 NseCDTrdSvr_2 >$LOGDIR/log.NseCDTrdSvr_2 2>&1&
fi;

if test "$1 " = "NseCDTrdSvr_3 "; then
        RunProcess NseCDTrdSvr_3 3 5 3 NseCDTrdSvr_3 >$LOGDIR/log.NseCDTrdSvr_3 2>&1&
fi;

if test "$1 " = "NseCDTrdSvr_4 "; then
        RunProcess NseCDTrdSvr_4 4 5 3 NseCDTrdSvr_4 >$LOGDIR/log.NseCDTrdSvr_4 2>&1&
fi;

if test "$1 " = "NseCDTrdSvr_5 "; then
        RunProcess NseCDTrdSvr_5 5 5 3 NseCDTrdSvr_5 >$LOGDIR/log.NseCDTrdSvr_5 2>&1&
fi;

if test "$1 " = "NseCDTrdSvr_6 "; then
        RunProcess NseCDTrdSvr_6 6 5 3  NseCDTrdSvr_6 >$LOGDIR/log.NseCDTrdSvr_6 2>&1&
fi;

if test "$1 " = "NseCDTrdSvr_7 "; then
        RunProcess NseCDTrdSvr_7 7 5 3 NseCDTrdSvr_7 >$LOGDIR/log.NseCDTrdSvr_7 2>&1&
fi;

if test "$1 " = "NseCDTrdSvr_8 "; then
        RunProcess NseCDTrdSvr_8 8 5 3 NseCDTrdSvr_8 >$LOGDIR/log.NseCDTrdSvr_8 2>&1&
fi;

if test "$1 " = "NseCDTrdSvr_9 "; then
        RunProcess NseCDTrdSvr_9 9 5 3 NseCDTrdSvr_9 >$LOGDIR/log.NseCDTrdSvr_9 2>&1&
fi;


if test "$1 " = "McxCOMCatalyst "; then
        RunProcess McxCOMCatalyst $INSTANCE_MCX_COM McxCOMCatalyst >$LOGDIR/log.McxCOMCatalyst 2>&1&
fi;

if test "$1 " = "McxCOMOrdSvr_1 "; then
        RunProcess McxCOMOrdSvr_1 1 McxCOMOrdSvr_1 >$LOGDIR/log.McxCOMOrdSvr_1  2>&1&
fi;

if test "$1 " = "McxCOMOrdSvr_2 "; then
        RunProcess McxCOMOrdSvr_2 2 McxCOMOrdSvr_2 >$LOGDIR/log.McxCOMOrdSvr_2  2>&1&
fi;

if test "$1 " = "McxCOMOrdSvr_3 "; then
        RunProcess McxCOMOrdSvr_3 3 McxCOMOrdSvr_3 >$LOGDIR/log.McxCOMOrdSvr_3  2>&1&
fi;

if test "$1 " = "McxCOMOrdSvr_4 "; then
        RunProcess McxCOMOrdSvr_4 4 McxCOMOrdSvr_4 >$LOGDIR/log.McxCOMOrdSvr_4  2>&1&
fi;

if test "$1 " = "McxCOMOrdSvr_5 "; then
        RunProcess McxCOMOrdSvr_5 5 McxCOMOrdSvr_5 >$LOGDIR/log.McxCOMOrdSvr_5  2>&1&
fi;

if test "$1 " = "McxCOMOrdSvr_6 "; then
        RunProcess McxCOMOrdSvr_6 6 McxCOMOrdSvr_6 >$LOGDIR/log.McxCOMOrdSvr_6  2>&1&
fi;

if test "$1 " = "McxCOMOrdSvr_7 "; then
        RunProcess McxCOMOrdSvr_7 7 McxCOMOrdSvr_7 >$LOGDIR/log.McxCOMOrdSvr_7  2>&1&
fi;

if test "$1 " = "McxCOMOrdSvr_8 "; then
        RunProcess McxCOMOrdSvr_8 8 McxCOMOrdSvr_8 >$LOGDIR/log.McxCOMOrdSvr_8  2>&1&
fi;

if test "$1 " = "McxCOMOrdSvr_9 "; then
        RunProcess McxCOMOrdSvr_9 9 McxCOMOrdSvr_9 >$LOGDIR/log.McxCOMOrdSvr_9  2>&1&
fi;

if test "$1 " = "McxCOMOrdSvr_10 "; then
        RunProcess McxCOMOrdSvr_10 10 McxCOMOrdSvr_10 > $LOGDIR/log.McxCOMOrdSvr_10 2>&1
fi;

if test "$1 " = "McxCOMOrdSvr_11 "; then
        RunProcess McxCOMOrdSvr_11 11 McxCOMOrdSvr_11 > $LOGDIR/log.McxCOMOrdSvr_11 2>&1
fi;

if test "$1 " = "McxCOMOrdSvr_12 "; then
        RunProcess McxCOMOrdSvr_12 12 McxCOMOrdSvr_12 > $LOGDIR/log.McxCOMOrdSvr_12 2>&1
fi;


if test "$1 " = "McxCOMOrdSvr_13 "; then
        RunProcess McxCOMOrdSvr_13 13 McxCOMOrdSvr_13 > $LOGDIR/log.McxCOMOrdSvr_13 2>&1
fi;

if test "$1 " = "McxCOMOrdSvr_14 "; then
        RunProcess McxCOMOrdSvr_14 14 McxCOMOrdSvr_14 > $LOGDIR/log.McxCOMOrdSvr_14 2>&1
fi;

if test "$1 " = "McxCOMOrdSvr_15 "; then
        RunProcess McxCOMOrdSvr_15 15 McxCOMOrdSvr_15 > $LOGDIR/log.McxCOMOrdSvr_15 2>&1
fi;

if test "$1 " = "McxCOMOrdSvr_16 "; then
        RunProcess McxCOMOrdSvr_16 16 McxCOMOrdSvr_16 > $LOGDIR/log.McxCOMOrdSvr_16 2>&1
fi;

if test "$1 " = "McxCOMOrdSvr_17 "; then
        RunProcess McxCOMOrdSvr_17 17 McxCOMOrdSvr_17 > $LOGDIR/log.McxCOMOrdSvr_17 2>&1
fi;

if test "$1 " = "McxCOMOrdSvr_18 "; then
        RunProcess McxCOMOrdSvr_18 18 McxCOMOrdSvr_18 > $LOGDIR/log.McxCOMOrdSvr_18 2>&1
fi;

if test "$1 " = "McxCOMOrdSvr_19 "; then
        RunProcess McxCOMOrdSvr_19 19 McxCOMOrdSvr_19 > $LOGDIR/log.McxCOMOrdSvr_19 2>&1
fi;

if test "$1 " = "McxCOMOrdSvr_20 "; then
        RunProcess McxCOMOrdSvr_20 20 McxCOMOrdSvr_20 > $LOGDIR/log.McxCOMOrdSvr_20 2>&1
fi;

if test "$1 " = "McxCOMOrdSvr_21 "; then
        RunProcess McxCOMOrdSvr_21 21 McxCOMOrdSvr_21 > $LOGDIR/log.McxCOMOrdSvr_21 2>&1
fi;

if test "$1 " = "McxCOMOrdSvr_22 "; then
        RunProcess McxCOMOrdSvr_22 22 McxCOMOrdSvr_22 > $LOGDIR/log.McxCOMOrdSvr_22 2>&1
fi;

if test "$1 " = "McxCOMOrdSvr_23 "; then
        RunProcess McxCOMOrdSvr_23 23 McxCOMOrdSvr_23 > $LOGDIR/log.McxCOMOrdSvr_23 2>&1
fi;

if test "$1 " = "McxCOMOrdSvr_24 "; then
        RunProcess McxCOMOrdSvr_24 24 McxCOMOrdSvr_24 > $LOGDIR/log.McxCOMOrdSvr_24 2>&1
fi;

if test "$1 " = "McxCOMOrdSvr_25 "; then
        RunProcess McxCOMOrdSvr_25 25 McxCOMOrdSvr_25 > $LOGDIR/log.McxCOMOrdSvr_25 2>&1
fi;

if test "$1 " = "McxCOMOrdSvr_26 "; then
        RunProcess McxCOMOrdSvr_26 26 McxCOMOrdSvr_26 > $LOGDIR/log.McxCOMOrdSvr_26 2>&1
fi;

if test "$1 " = "McxCOMOrdSvr_27 "; then
        RunProcess McxCOMOrdSvr_27 27 McxCOMOrdSvr_27 > $LOGDIR/log.McxCOMOrdSvr_27 2>&1
fi;

if test "$1 " = "McxCOMOrdSvr_28 "; then
        RunProcess McxCOMOrdSvr_28 28 McxCOMOrdSvr_28 > $LOGDIR/log.McxCOMOrdSvr_28 2>&1
fi;

if test "$1 " = "McxCOMOrdSvr_29 "; then
        RunProcess McxCOMOrdSvr_29 29 McxCOMOrdSvr_29 > $LOGDIR/log.McxCOMOrdSvr_29 2>&1
fi;

if test "$1 " = "McxCOMOrdSvr_30 "; then
        RunProcess McxCOMOrdSvr_30 30 McxCOMOrdSvr_30 > $LOGDIR/log.McxCOMOrdSvr_30 2>&1
fi;


if test "$1 " = "McxCOMTrdSvr_1 "; then
        RunProcess McxCOMTrdSvr_1 1 5 3  McxCOMTrdSvr_1 >$LOGDIR/log.McxCOMTrdSvr_1 2>&1&
fi;

if test "$1 " = "McxCOMTrdSvr_2 "; then
        RunProcess McxCOMTrdSvr_2 2 5 3  McxCOMTrdSvr_2 >$LOGDIR/log.McxCOMTrdSvr_2 2>&1&
fi;

if test "$1 " = "McxCOMTrdSvr_3 "; then
        RunProcess McxCOMTrdSvr_3 3 5 3  McxCOMTrdSvr_3 >$LOGDIR/log.McxCOMTrdSvr_3 2>&1&
fi;

if test "$1 " = "McxCOMTrdSvr_4 "; then
        RunProcess McxCOMTrdSvr_4 4 5 3  McxCOMTrdSvr_4 >$LOGDIR/log.McxCOMTrdSvr_4 2>&1&
fi;

if test "$1 " = "McxCOMTrdSvr_5 "; then
        RunProcess McxCOMTrdSvr_5 5 5 3  McxCOMTrdSvr_5 >$LOGDIR/log.McxCOMTrdSvr_5 2>&1&
fi;

if test "$1 " = "McxCOMTrdSvr_6 "; then
        RunProcess McxCOMTrdSvr_6 6 5 3  McxCOMTrdSvr_6 >$LOGDIR/log.McxCOMTrdSvr_6 2>&1&
fi;

if test "$1 " = "McxCOMTrdSvr_7 "; then
        RunProcess McxCOMTrdSvr_7 7 5 3  McxCOMTrdSvr_7 >$LOGDIR/log.McxCOMTrdSvr_7 2>&1&
fi;

if test "$1 " = "McxCOMTrdSvr_8 "; then
        RunProcess McxCOMTrdSvr_8 8 5 3  McxCOMTrdSvr_8 >$LOGDIR/log.McxCOMTrdSvr_8 2>&1&
fi;

if test "$1 " = "McxCOMTrdSvr_9 "; then
        RunProcess McxCOMTrdSvr_9 9 5 3  McxCOMTrdSvr_9 >$LOGDIR/log.McxCOMTrdSvr_9 2>&1&
fi;

if test "$1 " = "NseCMRevCatalyst "; then
        RunProcess NseCMRevCatalyst 9  NseCMRevCatalyst >$LOGDIR/log.NseCMRevCatalyst 2>&1&
fi;

if test "$1 " = "NseCMRevMap_1 "; then
        RunProcess NseCMRevMap_1 1  NseCMRevMap_1 >$LOGDIR/log.NseCMRevMap_1 2>&1&
fi;

if test "$1 " = "NseCMRevMap_2 "; then
        RunProcess NseCMRevMap_2 2  NseCMRevMap_2 >$LOGDIR/log.NseCMRevMap_2 2>&1&
fi;

if test "$1 " = "NseCMRevMap_3 "; then
        RunProcess NseCMRevMap_3 3  NseCMRevMap_3 >$LOGDIR/log.NseCMRevMap_3 2>&1&
fi;

if test "$1 " = "NseCMRevMap_4 "; then
        RunProcess NseCMRevMap_4 4  NseCMRevMap_4 >$LOGDIR/log.NseCMRevMap_4 2>&1&
fi;

if test "$1 " = "NseCMRevMap_5 "; then
        RunProcess NseCMRevMap_5 5  NseCMRevMap_5 >$LOGDIR/log.NseCMRevMap_5 2>&1&
fi;

if test "$1 " = "NseCMRevMap_6 "; then
        RunProcess NseCMRevMap_6 6  NseCMRevMap_6 >$LOGDIR/log.NseCMRevMap_6 2>&1&
fi;

if test "$1 " = "NseCMRevMap_7 "; then
        RunProcess NseCMRevMap_7 7  NseCMRevMap_7 >$LOGDIR/log.NseCMRevMap_7 2>&1&
fi;

if test "$1 " = "NseCMRevMap_8 "; then
        RunProcess NseCMRevMap_8 8  NseCMRevMap_8 >$LOGDIR/log.NseCMRevMap_8 2>&1&
fi;

if test "$1 " = "NseCMRevMap_9 "; then
        RunProcess NseCMRevMap_9 9  NseCMRevMap_9 >$LOGDIR/log.NseCMRevMap_9 2>&1&
fi;

if test "$1 " = "NseCMRevCatMMap_1 "; then
        RunProcess NseCMRevCatMMap_1 1 NseCMRevCatMMap_1 >$LOGDIR/log.NseCMRevCatMMap_1 2>&1&
fi;

if test "$1 " = "NseCMRevCatMMap_2 "; then
        RunProcess NseCMRevCatMMap_2 2 NseCMRevCatMMap_2 >$LOGDIR/log.NseCMRevCatMMap_2 2>&1&
fi;


if test "$1 " = "NseCMRevCatMMap_3 "; then
        RunProcess NseCMRevCatMMap_3 3 NseCMRevCatMMap_3 >$LOGDIR/log.NseCMRevCatMMap_3 2>&1&
fi;

if test "$1 " = "NseCMRevCatMMap_4 "; then
        RunProcess NseCMRevCatMMap_4 4 NseCMRevCatMMap_4 >$LOGDIR/log.NseCMRevCatMMap_4 2>&1&
fi;

if test "$1 " = "NseCMRevCatMMap_5 "; then
        RunProcess NseCMRevCatMMap_5 5 NseCMRevCatMMap_5 >$LOGDIR/log.NseCMRevCatMMap_5 2>&1&
fi;

if test "$1 " = "NseCMRevCatMMap_6 "; then
        RunProcess NseCMRevCatMMap_6 6 NseCMRevCatMMap_6 >$LOGDIR/log.NseCMRevCatMMap_6 2>&1&
fi;

if test "$1 " = "NseCMRevCatMMap_7 "; then
        RunProcess NseCMRevCatMMap_7 7 NseCMRevCatMMap_7 >$LOGDIR/log.NseCMRevCatMMap_7 2>&1&
fi;

if test "$1 " = "NseCMRevCatMMap_8 "; then
        RunProcess NseCMRevCatMMap_8 8 NseCMRevCatMMap_8 >$LOGDIR/log.NseCMRevCatMMap_8 2>&1&
fi;

if test "$1 " = "NseCMRevCatMMap_9 "; then
        RunProcess NseCMRevCatMMap_9 9 NseCMRevCatMMap_9 >$LOGDIR/log.NseCMRevCatMMap_9 2>&1&
fi;

if test "$1 " = "NseCDmarkSim "; then
        RunProcess NseCDmarkSim $GROUP_ID 10 9 NseCDmarkSim >$LOGDIR/log.NseCDmarkSim 2>&1&
fi;

if test "$1 " = "BseCDOrdSvr_1 "; then
        RunProcess BseCDOrdSvr_1 1 BseCDOrdSvr_1 >$LOGDIR/log.BseCDOrdSvr_1  2>&1&
fi;

if test "$1 " = "BseCDOrdSvr_2 "; then
        RunProcess BseCDOrdSvr_2 2 BseCDOrdSvr_2 >$LOGDIR/log.BseCDOrdSvr_2  2>&1&
fi;

if test "$1 " = "BseCDOrdSvr_3 "; then
        RunProcess BseCDOrdSvr_3 3 BseCDOrdSvr_3 >$LOGDIR/log.BseCDOrdSvr_3  2>&1&
fi;

if test "$1 " = "BseCDOrdSvr_4 "; then
        RunProcess BseCDOrdSvr_4 4 BseCDOrdSvr_4 >$LOGDIR/log.BseCDOrdSvr_4  2>&1&
fi;

if test "$1 " = "BseCDOrdSvr_5 "; then
        RunProcess BseCDOrdSvr_5 5 BseCDOrdSvr_5 >$LOGDIR/log.BseCDOrdSvr_5  2>&1&
fi;

if test "$1 " = "BseCDOrdSvr_6 "; then
        RunProcess BseCDOrdSvr_6 6 BseCDOrdSvr_6 >$LOGDIR/log.BseCDOrdSvr_6  2>&1&
fi;

if test "$1 " = "BseCDOrdSvr_7 "; then
        RunProcess BseCDOrdSvr_7 7 BseCDOrdSvr_7 >$LOGDIR/log.BseCDOrdSvr_7  2>&1&
fi;

if test "$1 " = "BseCDOrdSvr_8 "; then
        RunProcess BseCDOrdSvr_8 8 BseCDOrdSvr_8 >$LOGDIR/log.BseCDOrdSvr_8  2>&1&
fi;

if test "$1 " = "BseCDOrdSvr_9 "; then
        RunProcess BseCDOrdSvr_9 9 BseCDOrdSvr_9 >$LOGDIR/log.BseCDOrdSvr_9  2>&1&
fi;


if test "$1 " = "BseCDTrdSvr_1 "; then
        RunProcess BseCDTrdSvr_1 1 5 3 BseCDTrdSvr_1 >$LOGDIR/log.BseCDTrdSvr_1 2>&1&
fi;

if test "$1 " = "BseCDTrdSvr_2 "; then
        RunProcess BseCDTrdSvr_2 2 5 3 BseCDTrdSvr_2 >$LOGDIR/log.BseCDTrdSvr_2 2>&1&
fi;

if test "$1 " = "BseCDTrdSvr_3 "; then
        RunProcess BseCDTrdSvr_3 3 5 3 BseCDTrdSvr_3 >$LOGDIR/log.BseCDTrdSvr_3 2>&1&
fi;

if test "$1 " = "BseCDTrdSvr_4 "; then
        RunProcess BseCDTrdSvr_4 4 5 3 BseCDTrdSvr_4 >$LOGDIR/log.BseCDTrdSvr_4 2>&1&
fi;

if test "$1 " = "BseCDTrdSvr_5 "; then
        RunProcess BseCDTrdSvr_5 5 5 3 BseCDTrdSvr_5 >$LOGDIR/log.BseCDTrdSvr_5 2>&1&
fi;

if test "$1 " = "BseCDTrdSvr_6 "; then
        RunProcess BseCDTrdSvr_6 6 5 3 BseCDTrdSvr_6 >$LOGDIR/log.BseCDTrdSvr_6 2>&1&
fi;

if test "$1 " = "BseCDTrdSvr_7 "; then
        RunProcess BseCDTrdSvr_7 7 5 3 BseCDTrdSvr_7 >$LOGDIR/log.BseCDTrdSvr_7 2>&1&
fi;

if test "$1 " = "BseCDTrdSvr_8 "; then
        RunProcess BseCDTrdSvr_8 8 5 3 BseCDTrdSvr_8 >$LOGDIR/log.BseCDTrdSvr_8 2>&1&
fi;

if test "$1 " = "BseCDTrdSvr_9 "; then
        RunProcess BseCDTrdSvr_9 9 5 3 BseCDTrdSvr_9 >$LOGDIR/log.BseCDTrdSvr_9 2>&1&
fi;

if test "$1 " = "BseCDmarkSim "; then
        RunProcess BseCDmarkSim $GROUP_ID 10 9 BseCDmarkSim >$LOGDIR/log.BseCDmarkSim 2>&1&
fi;

if test "$1 " = "BseCDFwdMemMap "; then
        RunProcess BseCDFwdMemMap BseCDFwdMemMap >$LOGDIR/log.BseCDFwdMemMap 2>&1&
fi;

if test "$1 " = "BseCDRevMemMap_1 "; then
        RunProcess BseCDRevMemMap_1 1  BseCDRevMemMap_1 >$LOGDIR/log.BseCDRevMemMap_1 2>&1&
fi;

if test "$1 " = "BseCDRevMemMap_2 "; then
        RunProcess BseCDRevMemMap_2 2  BseCDRevMemMap_2 >$LOGDIR/log.BseCDRevMemMap_2 2>&1&
fi;

if test "$1 " = "BseCDRevMemMap_3 "; then
        RunProcess BseCDRevMemMap_3 3  BseCDRevMemMap_3 >$LOGDIR/log.BseCDRevMemMap_3 2>&1&
fi;
if test "$1 " = "BseCDRevMemMap_4 "; then
        RunProcess BseCDRevMemMap_4 4  BseCDRevMemMap_4 >$LOGDIR/log.BseCDRevMemMap_4 2>&1&
fi;

if test "$1 " = "BseCDRevMemMap_5 "; then
        RunProcess BseCDRevMemMap_5 5  BseCDRevMemMap_5 >$LOGDIR/log.BseCDRevMemMap_5 2>&1&
fi;

if test "$1 " = "BseCDRevMemMap_6 "; then
        RunProcess BseCDRevMemMap_6 6  BseCDRevMemMap_6 >$LOGDIR/log.BseCDRevMemMap_6 2>&1&
fi;

if test "$1 " = "BseCDRevMemMap_7 "; then
        RunProcess BseCDRevMemMap_7 7  BseCDRevMemMap_7 >$LOGDIR/log.BseCDRevMemMap_7 2>&1&
fi;

if test "$1 " = "BseCDRevMemMap_8 "; then
        RunProcess BseCDRevMemMap_8 8  BseCDRevMemMap_8 >$LOGDIR/log.BseCDRevMemMap_8 2>&1&
fi;

if test "$1 " = "BseCDRevMemMap_9 "; then
        RunProcess BseCDRevMemMap_9 9  BseCDRevMemMap_9 >$LOGDIR/log.BseCDRevMemMap_9 2>&1&
fi;

if test "$1 " = "BseCDRevMap "; then
        RunProcess BseCDRevMap 9 BseCDRevMap >$LOGDIR/log.BseCDRevMap 2>&1&
fi;

if test "$1 " = "BseCDCatalyst "; then
        RunProcess BseCDCatalyst 9  BseCDCatalyst >$LOGDIR/log.BseCDCatalyst 2>&1&
fi;

if test "$1 " = "BseCDCOBOPump "; then
        RunProcess BseCDCOBOPump 0 BseCDCOBOPump >$LOGDIR/log.BseCDCOBOPump 2>&1&
fi;

if test "$1 " = "BseCDBcastAdap "; then
        #RunProcess BseCDBcastAdap 2363 5450 L  EquBseDump.dmp  N EquBse23feb2012.dmp  B  BseCDBcastAdap >$LOGDIR/log.BseCDBcastAdap 2>&1&
	#RunProcess BseCDBcastAdap 2364 $BCURR_BROADCAST_TYPE L EquBseDump.dmp N EquBse23feb2012.dmp D BseCDBcastAdap >$LOGDIR/log.BseCDBcastAdap 2>&1&
	RunProcess BseCDBcastAdap 2363 $BCURR_BCAST_RECV_PORT L EquBseDump.dmp N EquBse23feb2012.dmp $BCURR_BROADCAST_TYPE BseCDBcastAdap >$LOGDIR/log.BseCDBcastAdap 2>&1&
fi;

if test "$1 " = "BseCDBcastSptr "; then
        RunProcess BseCDBcastSptr  BseCDBcastSptr >$LOGDIR/log.BseCDBcastSptr 2>&1&
fi;

if test "$1 " = "BseCDMktStat "; then
        RunProcess BseCDMktStat BseCDMktStat >$LOGDIR/log.BseCDMktStat 2>&1&
fi;

if test "$1 " = "BseCDSAddMbpUpd "; then
        RunProcess BseCDSAddMbpUpd $MAX_NEQ_MBP_THREAD 1  BseCDSAddMbpUpd >$LOGDIR/log.BseCDSAddMbpUpd 2>&1&
fi;

if test "$1 " = "BseCDSMemMbpUpd "; then
        RunProcess BseCDSMemMbpUpd $MAX_NEQ_MBP_THREAD 1  BseCDSMemMbpUpd >$LOGDIR/log.BseCDSMemMbpUpd 2>&1&
fi;

if test "$1 " = "TradeNotifier "; then
        RunProcess TradeNotifier 10  TradeNotifier >$LOGDIR/log.TradeNotifier 2>&1&
fi;

if test "$1 " = "KFreadwrite "; then
        RunProcess KFreadwrite $RS_KAFKA_HOST_PORT 1 $KAFKA_NOTIFY_TOPIC CHELSEAFC KFreadwrite >$LOGDIR/log.KFreadwrite 2>&1&
fi;

if test "$1 " = "OrderProcessNEQ "; then
        RunProcess OrderProcessNEQ 1 OrderProcessNEQ > $LOGDIR/log.OrderProcessNEQ 2>&1&
fi;

if test "$1 " = "OrderProcessNFO "; then
	RunProcess OrderProcessNFO 2 OrderProcessNFO > $LOGDIR/log.OrderProcessNFO 2>&1&
fi;

if test "$1 " = "OrderProcessNCD "; then
	RunProcess OrderProcessNCD 3 OrderProcessNCD > $LOGDIR/log.OrderProcessNCD 2>&1&
fi;

if test "$1 " = "OrderProcessBEQ "; then
	RunProcess OrderProcessBEQ 4 OrderProcessBEQ > $LOGDIR/log.OrderProcessBEQ 2>&1&
fi;

if test "$1 " = "OrderProcessMCX "; then
	RunProcess OrderProcessMCX 5 OrderProcessMCX > $LOGDIR/log.OrderProcessMCX 2>&1&
fi;

if test "$1 " = "NotifyProcess "; then
        RunProcess NotifyProcess NotifyProcess >$LOGDIR/log.NotifyProcess 2>&1&
fi;

if test "$1 " = "DWSD2C1 "; then
        RunProcess DWSD2C1 $DWS_D2C1_PORT_PRI $DD2C1_CONNECT_PORT_PRI 0  DWSD2C1 >$LOGDIR/log.DWSD2C1 2>&1&
fi;

if test "$1 " = "KafkaAdaptor "; then
        RunProcess KafkaAdaptor $RS_KAFKA_HOST_PORT 2 $KAFKA_NOTIFY_TOPIC CHELSEAFC KafkaAdaptor >$LOGDIR/log.KafkaAdaptor 2>&1&
fi;

if test "$1 " = "BseFOBcastAdap "; then
        RunProcess BseFOBcastAdap 2363 $BSE_FO_BCAST_RECV_PORT L  EquBseDump.dmp  N EquBse23feb2012.dmp  B  BseFOBcastAdap >$LOGDIR/log.BseFOBcastAdap 2>&1&
fi;

if test "$1 " = "BseFOBcastSptr "; then
        RunProcess BseFOBcastSptr  BseFOBcastSptr >$LOGDIR/log.BseFOBcastSptr 2>&1&
fi;

if test "$1 " = "BseFOSMemMbpUpd "; then
       RunProcess BseFOSMemMbpUpd 3  BseFOSMemMbpUpd >/dev/null 2>&1&
        RunProcess BseFOSMemMbpUpd 3  BseFOSMemMbpUpd >$LOGDIR/log.BseFOSMemMbpUpd 2>&1&
fi;

if test "$1 " = "BseFOSAddMbpUpd "; then
        RunProcess BseFOSAddMbpUpd  1 BseFOSAddMbpUpd >$LOGDIR/log.BseFOSAddMbpUpd 2>&1&
       RunProcess BseFOSAddMbpUpd  1 BseFOSAddMbpUpd >/dev/null 2>&1&
fi;

if test "$1 " = "BseFOSAddMbpUpd "; then
        RunProcess BseFOSAddMbpUpd  1 BseFOSAddMbpUpd >$LOGDIR/log.BseFOSAddMbpUpd 2>&1&
       RunProcess BseFOSAddMbpUpd  1 BseFOSAddMbpUpd >/dev/null 2>&1&
fi;

if test "$1 " = "BseFOMktStat "; then
        RunProcess BseFOMktStat BseFOMktStat >$LOGDIR/log.BseFOMktStat 2>&1&
fi;

if test "$1 " = "BseFORevMap "; then
         RunProcess BseFORevMap  1  BseFORevMap > $LOGDIR/log.BseFORevMap 2>&1
fi;

if test "$1 " = "BseFOOrdSvr_1 "; then
        RunProcess BseFOOrdSvr_1 1  BseFOOrdSvr_1 >$LOGDIR/log.BseFOOrdSvr_1  2>&1&
fi;

if test "$1 " = "BseFOOrdSvr_2 "; then
        RunProcess BseFOOrdSvr_2 2  BseFOOrdSvr_2 >$LOGDIR/log.BseFOOrdSvr_2  2>&1&
fi;

if test "$1 " = "BseFOOrdSvr_3 "; then
        RunProcess BseFOOrdSvr_3 3  BseFOOrdSvr_3 >$LOGDIR/log.BseFOOrdSvr_3  2>&1&
fi;

if test "$1 " = "BseFOOrdSvr_4 "; then
        RunProcess BseFOOrdSvr_4 4  BseFOOrdSvr_4 >$LOGDIR/log.BseFOOrdSvr_4  2>&1&
fi;

if test "$1 " = "BseFOOrdSvr_5 "; then
        RunProcess BseFOOrdSvr_5 5  BseFOOrdSvr_5 >$LOGDIR/log.BseFOOrdSvr_5 2>&1&
fi;

if test "$1 " = "BseFOOrdSvr_6 "; then
        RunProcess BseFOOrdSvr_6 6  BseFOOrdSvr_6 >$LOGDIR/log.BseFOOrdSvr_6  2>&1&
fi;

if test "$1 " = "BseFOOrdSvr_7 "; then
        RunProcess BseFOOrdSvr_7 7  BseFOOrdSvr_7 >$LOGDIR/log.BseFOOrdSvr_7  2>&1&
fi;

if test "$1 " = "BseFOOrdSvr_8 "; then
        RunProcess BseFOOrdSvr_8 8  BseFOOrdSvr_8 >$LOGDIR/log.BseFOOrdSvr_8  2>&1&
fi;

if test "$1 " = "BseFOOrdSvr_9 "; then
        RunProcess BseFOOrdSvr_9 9  BseFOOrdSvr_9 >$LOGDIR/log.BseFOOrdSvr_9  2>&1&
fi;

if test "$1 " = "BseFOOrdSvr_10 "; then
        RunProcess BseFOOrdSvr_10 10  BseFOOrdSvr_10 >$LOGDIR/log.BseFOOrdSvr_10  2>&1&
fi;

if test "$1 " = "BseFOOrdSvr_11 "; then
        RunProcess BseFOOrdSvr_11 11  BseFOOrdSvr_11 >$LOGDIR/log.BseFOOrdSvr_11  2>&1&
fi;

if test "$1 " = "BseFOOrdSvr_12 "; then
        RunProcess BseFOOrdSvr_12 12  BseFOOrdSvr_12 >$LOGDIR/log.BseFOOrdSvr_12  2>&1&
fi;

if test "$1 " = "BseFOOrdSvr_13 "; then
        RunProcess BseFOOrdSvr_13 13  BseFOOrdSvr_13 >$LOGDIR/log.BseFOOrdSvr_13  2>&1&
fi;

if test "$1 " = "BseFOOrdSvr_14 "; then
        RunProcess BseFOOrdSvr_14 14  BseFOOrdSvr_14 >$LOGDIR/log.BseFOOrdSvr_14  2>&1&
fi;

if test "$1 " = "BseFOOrdSvr_15 "; then
        RunProcess BseFOOrdSvr_15 15  BseFOOrdSvr_15 >$LOGDIR/log.BseFOOrdSvr_15  2>&1&
fi;

if test "$1 " = "BseFOOrdSvr_16 "; then
        RunProcess BseFOOrdSvr_16 16  BseFOOrdSvr_16 >$LOGDIR/log.BseFOOrdSvr_16  2>&1&
fi;
if test "$1 " = "BseFOOrdSvr_17 "; then
        RunProcess BseFOOrdSvr_17 17  BseFOOrdSvr_17 >$LOGDIR/log.BseFOOrdSvr_17  2>&1&
fi;
if test "$1 " = "BseFOOrdSvr_18 "; then
        RunProcess BseFOOrdSvr_18 18  BseFOOrdSvr_18 >$LOGDIR/log.BseFOOrdSvr_18  2>&1&
fi;
if test "$1 " = "BseFOOrdSvr_19 "; then
        RunProcess BseFOOrdSvr_19 19  BseFOOrdSvr_19 >$LOGDIR/log.BseFOOrdSvr_19  2>&1&
fi;
if test "$1 " = "BseFOOrdSvr_20 "; then
        RunProcess BseFOOrdSvr_20 20  BseFOOrdSvr_20 >$LOGDIR/log.BseFOOrdSvr_20  2>&1&
fi;
if test "$1 " = "BseFOOrdSvr_21 "; then
        RunProcess BseFOOrdSvr_21 21  BseFOOrdSvr_21 >$LOGDIR/log.BseFOOrdSvr_21  2>&1&
fi;
if test "$1 " = "BseFOOrdSvr_22 "; then
        RunProcess BseFOOrdSvr_22 22  BseFOOrdSvr_22 >$LOGDIR/log.BseFOOrdSvr_22  2>&1&
fi;
if test "$1 " = "BseFOOrdSvr_23 "; then
        RunProcess BseFOOrdSvr_23 23  BseFOOrdSvr_23 >$LOGDIR/log.BseFOOrdSvr_23  2>&1&
fi;
if test "$1 " = "BseFOOrdSvr_24 "; then
        RunProcess BseFOOrdSvr_24 24  BseFOOrdSvr_24 >$LOGDIR/log.BseFOOrdSvr_24  2>&1&
fi;
if test "$1 " = "BseFOOrdSvr_25 "; then
        RunProcess BseFOOrdSvr_25 25  BseFOOrdSvr_25 >$LOGDIR/log.BseFOOrdSvr_25  2>&1&
fi;
if test "$1 " = "BseFOOrdSvr_26 "; then
        RunProcess BseFOOrdSvr_26 26  BseFOOrdSvr_26 >$LOGDIR/log.BseFOOrdSvr_26  2>&1&
fi;
if test "$1 " = "BseFOOrdSvr_27 "; then
        RunProcess BseFOOrdSvr_27 27  BseFOOrdSvr_27 >$LOGDIR/log.BseFOOrdSvr_27  2>&1&
fi;
if test "$1 " = "BseFOOrdSvr_28 "; then
        RunProcess BseFOOrdSvr_28 28  BseFOOrdSvr_28 >$LOGDIR/log.BseFOOrdSvr_28  2>&1&
fi;
if test "$1 " = "BseFOOrdSvr_29 "; then
        RunProcess BseFOOrdSvr_29 29  BseFOOrdSvr_29 >$LOGDIR/log.BseFOOrdSvr_29  2>&1&
fi;
if test "$1 " = "BseFOOrdSvr_30 "; then
        RunProcess BseFOOrdSvr_30 30  BseFOOrdSvr_30 >$LOGDIR/log.BseFOOrdSvr_30  2>&1&
fi;

if test "$1 " = "BseFOTrdSvr_1 "; then
        RunProcess BseFOTrdSvr_1 1 5 3 BseFOTrdSvr_1 >$LOGDIR/log.BseFOTrdSvr_1 2>&1&
fi;

if test "$1 " = "BseFOTrdSvr_2 "; then
        RunProcess BseFOTrdSvr_2 2 5 3 BseFOTrdSvr_2 >$LOGDIR/log.BseFOTrdSvr_2 2>&1&
fi;

if test "$1 " = "BseFOTrdSvr_3 "; then
        RunProcess BseFOTrdSvr_3 3 5 3 BseFOTrdSvr_3 >$LOGDIR/log.BseFOTrdSvr_3 2>&1&
fi;

if test "$1 " = "BseFOTrdSvr_4 "; then
        RunProcess BseFOTrdSvr_4 4 5 3 BseFOTrdSvr_4 >$LOGDIR/log.BseFOTrdSvr_4 2>&1&
fi;

if test "$1 " = "BseFOTrdSvr_5 "; then
        RunProcess BseFOTrdSvr_5 5 5 3 BseCDTrdSvr_5 >$LOGDIR/log.BseCDTrdSvr_5 2>&1&
fi;

if test "$1 " = "BseFOTrdSvr_6 "; then
        RunProcess BseFOTrdSvr_6 6 5 3 BseFOTrdSvr_6 >$LOGDIR/log.BseFOTrdSvr_6 2>&1&
fi;

if test "$1 " = "BseFOTrdSvr_7 "; then
        RunProcess BseFOTrdSvr_7 7 5 3 BseFOTrdSvr_7 >$LOGDIR/log.BseFOTrdSvr_7 2>&1&
fi;

if test "$1 " = "BseFOTrdSvr_8 "; then
        RunProcess BseFOTrdSvr_8 8 5 3 BseFOTrdSvr_8 >$LOGDIR/log.BseFOTrdSvr_8 2>&1&
fi;

if test "$1 " = "BseFOTrdSvr_9 "; then
        RunProcess BseFOTrdSvr_9 9 5 3 BseFOTrdSvr_9 >$LOGDIR/log.BseFOTrdSvr_9 2>&1&
fi;

if test "$1 " = "BseFORevMemMap_1 "; then
        RunProcess BseFORevMemMap_1 1  BseFORevMemMap_1 >$LOGDIR/log.BseFORevMemMap_1 2>&1&
fi;

if test "$1 " = "BseFORevMemMap_2 "; then
        RunProcess BseFORevMemMap_2 2  BseFORevMemMap_2 >$LOGDIR/log.BseFORevMemMap_2 2>&1&
fi;

if test "$1 " = "BseFORevMemMap_3 "; then
        RunProcess BseFORevMemMap_3 3  BseFORevMemMap_3 >$LOGDIR/log.BseFORevMemMap_3 2>&1&
fi;
if test "$1 " = "BseFORevMemMap_4 "; then
        RunProcess BseFORevMemMap_4 4  BseFORevMemMap_4 >$LOGDIR/log.BseFORevMemMap_4 2>&1&
fi;

if test "$1 " = "BseFORevMemMap_5 "; then
        RunProcess BseFORevMemMap_5 5  BseFORevMemMap_5 >$LOGDIR/log.BseFORevMemMap_5 2>&1&
fi;

if test "$1 " = "BseFORevMemMap_6 "; then
        RunProcess BseFORevMemMap_6 6  BseFORevMemMap_6 >$LOGDIR/log.BseFORevMemMap_6 2>&1&
fi;

if test "$1 " = "BseFORevMemMap_7 "; then
        RunProcess BseFORevMemMap_7 7  BseFORevMemMap_7 >$LOGDIR/log.BseFORevMemMap_7 2>&1&
fi;

if test "$1 " = "BseFORevMemMap_8 "; then
        RunProcess BseFORevMemMap_8 8  BseFORevMemMap_8 >$LOGDIR/log.BseFORevMemMap_8 2>&1&
fi;

if test "$1 " = "BseFORevMemMap_9 "; then
        RunProcess BseFORevMemMap_9 9  BseFORevMemMap_9 >$LOGDIR/log.BseFORevMemMap_9 2>&1&
fi;

if test "$1 " = "IntSqrOffBDrv "; then
	RunProcess IntSqrOffBDrv 19 IntSqrOffBDrv >$LOGDIR/log.IntSqrOffBDrv 2>&1&
fi;

if test "$1 " = "NseCMBoxAdap "; then
        RunProcess NseCMBoxAdap $TAP_IP1 $TAP_PORT1 $TAP_FAILOVER_IP1 $TAP_FAILOVER_PORT1 $NSE_CM_BOX_PORT $NSE_CM_LOG_ID NseCMBoxAdap >$LOGDIR/log.NseCMBoxAdap 2>&1&
fi;

if test "$1 " = "NseCMExchAdap "; then
       RunProcess NseCMExchAdap $TAP_EXCH_SIM1 $GROUP_ID $NSE_CM_BOX_IP $NSE_CM_BOX_PORT $NSE_CM_LOG_ID NseCMExchAdap >$LOGDIR/log.NseCMExchAdap 2>&1&
fi;

if test "$1 " = "NseFOBoxAdap "; then
        RunProcess NseFOBoxAdap $DRV_TAP_IP $DRV_TAP_PORT $DRV_TAP_FAILOVER_IP $DRV_TAP_FAILOVER_PORT $DRV_BOX_PORT $DRV_LOG_ID NseFOBoxAdap >$LOGDIR/log.NseFOBoxAdap 2>&1&
fi;

if test "$1 " = "NseFOExchAdap "; then
        RunProcess NseFOExchAdap $DRV_TAP_EXCH_SIM $GROUP_ID $DRV_BOX_IP $DRV_BOX_PORT $DRV_LOG_ID NseFOExchAdap >$LOGDIR/log.NseFOExchAdap 2>&1&
fi;

if test "$1 " = "NseCDExchAdap "; then
        RunProcess NseCDExchAdap $CUR_TAP_EXCH_SIM $GROUP_ID $CUR_BOX_IP $CUR_BOX_PORT $CUR_LOG_ID NseCDExchAdap >$LOGDIR/log.NseCDExchAdap 2>&1&
fi;

if test "$1 " = "BseCMBoxAdap "; then
        RunProcess BseCMBoxAdap $BSE_CM_BOX_PORT $BSE_CM_LOG_ID BseCMBoxAdap >$LOGDIR/log.BseCMBoxAdap 2>&1&
fi;

if test "$1 " = "BseFOBoxAdap "; then
        RunProcess BseFOBoxAdap $BSE_FO_BOX_PORT $BSE_FO_LOG_ID BseFOBoxAdap >$LOGDIR/log.BseFOBoxAdap 2>&1&
fi;

if test "$1 " = "BseFOExchAdap "; then
        #RunProcess BseFOExchAdap $GROUP_ID BseFOExchAdap >$LOGDIR/log.BseFOExchAdap 2>&1&
        RunProcess BseFOExchAdap $GROUP_ID $BSE_FO_BOX_IP $BSE_FO_BOX_PORT $BSE_FO_LOG_ID BseFOExchAdap >$LOGDIR/log.BseFOExchAdap 2>&1
fi;

