#!/bin/sh
#Script is used to measure ping statistics for specific site
sleep 2
#SET SITE
SITE=$1
PRIORITY=$2
#SET INTERVAL - Note: Set the INTERVAL as CRON_INTERVAL*60sec-5sec, usually 290
INTERVAL=290

SCRIPT_DIR="/philly_rsync/scripts/GENERAL/script_utilities/"
WORK_DIR="$SCRIPT_DIR/PingStats/LOGS"
DAY_FILE=$WORK_DIR/PingStat_`/bin/date +%Y_%m_%d`_SITE_$SITE
TIME=`/bin/date '+%H:%M'`
FILE=$WORK_DIR/PingStat.`/bin/date +%Y_%m_%d_%T`.$SITE
FILE_TAIL=$WORK_DIR/PingStat.`/bin/date +%Y_%m_%d_%T`tail.$SITE

#Format of the output file
#StartTime/LostPackets/MinPing/AvgPing/MaxPing/mdev
if [ ! -f ${DAY_FILE} ]; then
	echo "StartTime/LostPackets/MinPing/AvgPing/MaxPing/mdev" > $DAY_FILE
fi

/bin/ping -i 5 $SITE > $FILE&
PS_NUM=$!
sleep $INTERVAL
kill -2 $PS_NUM
sleep 5

/usr/bin/tail -2 $FILE>$FILE_TAIL

#Sometime, output of the ping command has info about "duplicate" packets. So if this is the case,
#position of "Packet Loss" is situated on different place.
#Also added the "errors" in egrep because in case "Destination Host Unreachable" there will be new "column" with "errors" in the output. See below.
#19 packets transmitted, 0 received, +12 errors, 100% packet loss, time 18030ms

DUPLICATES=`/usr/bin/head -1 $FILE_TAIL |grep -E 'duplicates|errors' |wc -l`
#DUPLICATES=`/usr/bin/head -1 $FILE_TAIL |grep duplicates |wc -l`
if [ "$DUPLICATES" -gt "0" ]; then
	        LOSS=`/usr/bin/head -1 $FILE_TAIL | /usr/bin/awk ' {print $8} '`
	else
		        LOSS=`/usr/bin/head -1 $FILE_TAIL | /usr/bin/awk ' {print $6} '`
				#LINE BELOW IS GOOD BUT FROM SOME REASON IT DOES NOT WORK ASSIGN TO THE VARIABLE FROM SOME REASON
				        #LOSS=`/usr/bin/head -1 $FILE_TAIL | /usr/bin/gawk '{a = gensub(/(.*), (.*)% packet loss(.*)/, "\\2", "g")} { print a}' `
fi

STAT=`/usr/bin/tail -1 $FILE_TAIL | /usr/bin/awk ' {print $4} '`
echo $TIME "/" $LOSS "/" $STAT >> $DAY_FILE

Loss=`echo $LOSS|cut -f1 -d"%"`
Ping=`echo $STAT|cut -f2 -d"/"|cut -f1 -d"."`

if [ "$PRIORITY" = "HIGH" ]; then 
	 MSG=""
	  if [ "$Loss" = "100" ]; then
		      $SCRIPT_DIR/PingStats/MailSender.sh emea.bgd.employees.mis@sungard.com "$TIME. Adresa $SITE je nedostupna" "Adresa $SITE je nedostupna"
		       else
			          if [ "$Loss" -gt "8" ]; then
					      MSG="GUBE SE PAKETI. Gubitak paketa $LOSS . Ping - $Ping."
					         fi
						    if [ "$Ping" -gt "200" ]; then
							        MSG=$MSG"PING JE LOS. Gubitak paketa $LOSS. Ping - $Ping . "
								   fi
								      if [ "$MSG" != "" ];then
									          MSG=$MSG" STAT: $STAT. "
										      SUBJ="$TIME - Check Internet Statistics for $SITE"
										          $SCRIPT_DIR/PingStats/MailSender.sh emea.bgd.employees.mis@sungard.com "$SUBJ" "$MSG"
											     fi
											      fi
fi

rm $FILE
rm $FILE_TAIL
