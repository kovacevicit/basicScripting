#!/bin/bash
echo "Vreme:  " >> topLog.txt
date >> topLog.txt
logging=`top -b -n 1 | head -n 12`
echo "$logging" >> topLog.txt
printf "\n \n \n" >> topLog.txt
echo "-----------------------------------------------------------------------------------------------" >> topLog.txt
printf "\n \n \n" >> topLog.txt
