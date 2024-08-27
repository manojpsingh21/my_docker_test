dos2unix ~/rupeeseed.env ~/.bashrc ~/Application/Exec/ShellScripts/AutoStartSystem.sh 
cd ~/Application/Exec/MonitoringTools/
find . -type f -exec dos2unix {} \;
cd ~/Application/Exec/ShellScripts/
find . -type f -exec dos2unix {} \;
