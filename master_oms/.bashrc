# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

export HISTTIMEFORMAT='%F %T'   #### AMAR ####

# User specific aliases and functions

. $HOME/rupeeseed.env
#. ./rupeeseed.env


PATH=.:$PATH
PATH=$PATH:.:$HOME/
PATH=$PATH:$HOME/Application/Exec/ShellScripts/:/usr/include/sys:$HOME/redis-4.0.9/Installed/bin
PATH=$PATH:$HOME/NodePath/bin
export PATH


#Alises
alias   wss="cd /home/rsapp4m/Application/ApacheTomcat/WSLogs/"
alias   cls="clear"
alias   l="ls -lst"
alias   ll="ls -lrt"
alias  	rm="echo 'You FOOL You are caught.... this will be reported to your GL'"
alias   dir="ls -l |grep ^d"
alias   files="ls -l | grep -v '^d'"
alias   links="ls -l | grep  '^l'"
alias   boottime="who -b"
alias   bep="cd $HOME/Application/Source/BseBcast/Equity/Proc"
alias   bdp="cd $HOME/Application/Source/BseBcast/Derivative/Proc"
alias   c="clear"
alias   go="cd $HOME/Application/Exec/Run"
alias   lo="cd $HOME/Application/Exec/Log"
alias   log="cd $HOME/Application/Exec/Log1"
alias   alo="cd $HOME/Application/Exec/AutoLog"
alias   mlo="cd $HOME/MCX_FIX_JAR/MCX_FIX/Log"
alias   sec="cd $HOME/Application/Exec/SecFileUpload"
alias   fp="cd $HOME/Application/Exec/ExcgFtp"
alias   po="cd $HOME/Application/Source"
alias   dws="cd $HOME/Application/Source/FEAdapter/DWSAdapter"
alias   tr="cd $HOME/Application/Source/Routers/TradeRouter"
alias   or="cd $HOME/Application/Source/Routers/OrderRouter"
alias   rmd="cd $HOME/Application/Source/RmsDirector/Proc"
alias   bk="cd $HOME/Application/Source/BackOffice"
alias   nbec="cd $HOME/Application/Source/NseBcast/Equity/C"
alias   rmsc="cd $HOME/Application/Source/RMS/C"
alias   rmss="cd $HOME/Application/Source/RMS/SQLC"
alias   ho="cd $HOME/Application/Source/Header"
alias   nb="cd $HOME/Application/Source/NseBcast"
alias   lb="cd $HOME/Application/Exec/Lib"
alias   nbe="cd $HOME/Application/Source/NseBcast/Equity/C"
alias   bbe="cd $HOME/Application/Source/BseBcast/Equity/C"
alias   mbc="cd $HOME/Application/Source/McxBcast/C"
alias   nbd="cd $HOME/Application/Source/NseBcast/Derivative/C"
alias   nbc="cd $HOME/Application/Source/NseBcast/Currency/C"
alias   co="cd $HOME/Application/Source/Common"
alias   cos="cd $HOME/Application/Source/Common/SQLC"
alias   coc="cd $HOME/Application/Source/Common/C"
alias   ap="cd $HOME/Application"
alias   u="ulinux -d"
alias   ram="free -h"
alias   space="df -kh"
alias   wap="cd $HOME/Application/Source/FEAdapter/WebAdapter"
alias   ud="UpdateAppAix -d"
alias   s="cd $HOME/Application/Exec/Run ;  $HOME/Application/Exec/ShellScripts/StartApp.sh"
alias   m="cd $HOME/Application/Makefile/; vi makefile.linux64;cd -"
alias   mk="cd $HOME/Application/Makefile/"
alias   ob="cd $HOME/Application/Objects/"
alias 	mt="cd $HOME/Application/Exec/Run ;  $HOME/Application/Exec/MonitoringTools/Menuopr.sh"
alias   p="cd Proc"
alias   S="cd ../SQLC"
alias   C="cd ../C"
alias   st="cd $HOME/Application/Exec/ShellScripts/  ;view StartSystem.sh ;cd -"
alias   Sa="view $HOME/Application/Exec/ShellScripts/StartApp.sh"
alias   sl="cd $HOME/Application/Exec/ShellScripts/"
alias   mo="cd $HOME/Application/Exec/MonitoringTools/"
alias   fl="cd $HOME/Application/Exec/File/"
alias   pyt="cd $HOME/Application/Exec/PythonScripts/"
alias   s+="sqlplus $USER_PASS"
alias   its="cd $HOME/Application/Source/FEAdapter/WebAdapter"
alias   whovi="ps -eaf | grep vi | grep $LOGNAME"
alias   shr="ShowUserRelay | wc -l"
alias   rm="rm -i"
alias   at="cd $HOME/Application/Source/AdvTrad"
alias   oec="cd $HOME/Application/Source/Servers/Orders/NSE/Equity/C"
alias	oes="cd $HOME/Application/Source/Servers/Orders/NSE/Equity/SQLC"
alias   odc="cd $HOME/Application/Source/Servers/Orders/NSE/Derivative/C"
alias   ods="cd $HOME/Application/Source/Servers/Orders/NSE/Derivative/SQLC"
alias   oxc="cd $HOME/Application/Source/Servers/Orders/MCX/Commodity/C"
alias   oxs="cd $HOME/Application/Source/Servers/Orders/MCX/Commodity/SQLC"
alias   tec="cd $HOME/Application/Source/Servers/Trades/NSE/Equity/C"
alias   tes="cd $HOME/Application/Source/Servers/Trades/NSE/Equity/SQLC"
alias   tdc="cd $HOME/Application/Source/Servers/Trades/NSE/Derivative/C"
alias   tds="cd $HOME/Application/Source/Servers/Trades/NSE/Derivative/SQLC"
alias   txc="cd $HOME/Application/Source/Servers/Trades/MCX/Commodity/C"
alias   txs="cd $HOME/Application/Source/Servers/Trades/MCX/Commodity/SQLC"
alias   gt="cd $HOME/Git"
alias	xm="cd $HOME/Application/Source/ExchMappers/C"
alias   in="cd $HOME/Application/Source/Interfaces/C"
alias   pf="ps -eaf | grep"
alias   nec="cd $HOME/Application/Source/Connect/NSE/Equity/C"
alias   ndc="cd $HOME/Application/Source/Connect/NSE/Derivative/C"
alias   ncc="cd $HOME/Application/Source/Connect/NSE/Currency/C"
alias   bec="cd $HOME/Application/Source/Connect/BSE/Equity/C"
alias   bdc="cd $HOME/Application/Source/Connect/BSE/Derivative/C"
alias   bcc="cd $HOME/Application/Source/Connect/BSE/Currency/C"
alias	nmfc="cd $HOME/Application/Source/Servers/Orders/NSE/MFSS/C"
alias	nmfs="cd $HOME/Application/Source/Servers/Orders/NSE/MFSS/SQLC"
alias   rr="cd $HOME/Application/Exec/RRService/"
alias   rs="cd $HOME/Application/ApacheTomcat/webapps/RupeeSeedWS/WEB-INF/classes/rupeeservice"
alias   rc="cd $HOME/Application/ApacheTomcat/webapps/RupeeSeedWS/WEB-INF/classes/rupeecontrollers"
alias   rbue="cd $HOME/Application/ApacheTomcat1/webapps/RupeeBootUE/WEB-INF/classes/"
alias   rb="cd $HOME/Application/ApacheTomcat1/webapps/RupeeBoot/WEB-INF/classes/"
alias   rn="cd $HOME/Application/ApacheTomcat1/webapps/RupeeNotifier/WEB-INF/classes/rupeecontrollers"
alias   rweb="cd $HOME/Application/ApacheTomcat/webapps/ROOT/WEB-INF/classes/"
alias   rweb1="cd $HOME/Application/ApacheTomcat1/webapps/ROOT/WEB-INF/classes/"
alias   wslo="cd $HOME/Application/ApacheTomcat/WSLogs40"
alias   wslo1="cd $HOME/Application/ApacheTomcat1/WSLogs40"
alias   wslo2="cd $HOME/Application/ApacheTomcat2/WSLogs40"
alias   wlog="cd $HOME/Application/ApacheTomcat/logs"
alias   wlog2="cd $HOME/Application/ApacheTomcat1/logs"
alias   wlog3="cd $HOME/Application/ApacheTomcat2/logs"
alias   wsb="cd $HOME/Application/ApacheTomcat/bin"
alias   wsb1="cd $HOME/Application/ApacheTomcat1/bin"
alias   wsb2="cd $HOME/Application/ApacheTomcat2/bin"
alias   wsi="cd $HOME/Application/ApacheTomcat/WSIpoLogs"
alias   wsi1="cd $HOME/Application/ApacheTomcat1/WSIpoLogs"
alias   wsi2="cd $HOME/Application/ApacheTomcat2/WSIpoLogs"
alias   htc="cd $HOME/Application/Apache2/conf/"
alias   psj="ps -eaf | grep --color java"
alias   pse="ps -eaf | grep --color NseCMExchAdap"
alias   psd="ps -eaf | grep --color NseFOExchAdap"
alias   psc="ps -eaf | grep --color NseCDExchAdap"
alias   pse="ps -eaf | grep --color BseCMExchAdap"


umask u=rwx,g=rwx,o=wrx

clear
sleep 1

SHACCT=./.loginfo


IP=`who am i | awk ' { print($6)}'`
#echo $IP

clear


lld() { file * | awk -F":" ' { print $1 , $2 } ' | awk ' $2 == "directory" { printf "%-30s %-30s\n", $1 , $2 } ' ; }
grepr() { find . -exec grep "$1" "$2" {} \; ; 2>/dev/null ; }

stat() { ps -eaf | grep $USER;}

search() { echo Enter the name of the file to search: ;
                printf "SEARCH ENGINE>";
          read filename;
                find $HOME -name "$star$filename$star" ;
                 }


bigfiles() { find . -ls | sort -k 7,7rn | head -10;  }

#For Dumping core files
ulimit -c 50000

#set -o vi

PS1="`echo RS_DEV_MASTER`:\$PWD > "
PS2=">"

SHELL=/bin/bash
export SHELL;


