 #!/bin/bash
#This scripts  is used for Kana Defunct Cleanup 

#***************************************************
       
	now=`date +"%Y%m%d-%H%M%S"`	
	
	logfile=$now.back.log
	exec > $logfile 2>&1


        echo "$now"

        host=`hostname`          # Capture Hostname

        echo "you are in host $host"

 	
	echo "$PWD"
        
        echo "********************************************************"

       # cd /opt/kana/prod/Verity650/k2/_ilnx*/bin
        cd /opt/kana/stage/Verity650/k2/_ilnx*/bin/

	./rcadmin -server $host -port 9950 -input ~/script/indexview.txt > ~/script/sc

	cat ~/script/indexingPR.txt | grep Alias: |awk '{print $2}' > ~/script/listPR.txt

 	a=`wc -l ~/script/listPR.txt | awk   '{print $1}' `

 	echo "$a"

  	a=$[$a-4]
 	echo "Count after deletion $a "


	head -n$a  ~/script/listPR.txt > ~/script/resultPR.txt
        tail -n 4 ~/script/listPR.txt  > ~/script/resultPR1.txt

	
                sed 's/hostname/'$host'/g' ~/script/deleteref.txt > ~/script/delete.txt

            
		while read line
		do
		echo $line
		sed '3 s/[0-9]*/'$line'/' ~/script/detach.txt  > ~/script/detaching.txt
		sed '3 s/[0-9]*/'$line'/' ~/script/delete.txt > ~/script/deleting.txt

		./rcadmin -server $host -port 9950 -input ~/script/detaching.txt
		sleep 5
		./rcadmin -server $host -port 9950 -input ~/script/deleting.txt
		sleep 5
	 	detachlog=`sed -n '3p' ~/script/detaching.txt`
	  	echo "$detachlog" >> ~/script/detachlog-$now.log

	  	deletelog=`sed -n '3p' ~/script/deleting.txt`
	  	echo "$deletelog" >> ~/script/deletelog-$now.log
            
	        done<~/script/resultPR.txt

              sleep 30


               echo "VERIFICATION PROCESS"
        		
               ./rcadmin -server $host -port 9950 -input ~/script/indexview.txt > ~/script/indexingPO.txt

		cat ~/script/indexingPO.txt | grep Alias: |awk '{print $2}' > ~/script/listPO.txt

 	
        	diff ~/script/listPO.txt ~/script/resultPR1.txt

 		if [ $? -eq 1 ]; then 
  
		echo "VERIFICATION FAILED "
                echo "TASK IS GOING TO ABORT "
                
                sleep 2
 	
                exit

		else 

		echo " VERIFIED SUCCESSFULLY "
                echo " Continuing TASK" 
                
          	fi

	   sleep 2

        cp -p ~/script/deletelog* /tmp/deletelog.txt

	

echo "************************************************************************************************************************"	



	echo " Script for restarting KanaKB Servers"
	echo "*******KANAKB STOPPING******* "

echo "$PWD"

#cd /opt/kana/prod/kanaiq/bin/
cd /opt/kana/stage/kanaiq/bin

if (( $(ps -ef | grep -v grep | grep k2 | wc -l) >=4 ))
then

sh k2adminstop.sh

ps axf | grep "k2" | grep -v grep | awk '{print  $1}'| sh


echo " Successfully stopped KanaKB "

else
echo " Service not running "
fi

sleep 30



echo "*******KANAKB START******* "


sh k2adminstart.sh

sleep 30 

if (( $(ps -ef | grep -v grep | grep k2 | wc -l) >=4 ))
then
echo "Successfully Started kaana kb"
else
echo " Failed  to start Kana kb"
 exit
fi

echo "************************************************************************************************"





echo " Kanna KB CleanUp" 
   echo "***********************************************"
  
 #  cd /opt/kana/prod/kanaiq/kanaIQRoot/knowledgebases
   cd /opt/kana/stage/kanaiq/kanaIQRoot/knowledgebases
   
   echo "$PWD"


   ls -lrt | tail -2 | awk '{ print $9 }' > /tmp/test.txt

   folder1=`head -n 1 /tmp/test.txt`

   cd "$folder1"

   echo " you are in folder $PWD "
   
   sleep 10


  while read line
do
echo $line

find . -name $line -type d -exec rm -r {} +

 
if [ $? -eq 0 ];
then
echo "Deleted "
else
echo " No such file"
fi
done</tmp/deletelog.txt


echo " Deleted Files in $PWD"


echo " ******************************************"

#      cd /opt/kana/prod/kanaiq/kanaIQRoot/knowledgebases
     cd /opt/kana/stage/kanaiq/kanaIQRoot/knowledgebases

     folder2=`tail -n 1 /tmp/test.txt`

     echo "$folder2"

    cd "$folder2"

    echo " you are in folder $PWD "

    sleep 10
    
     while read line
do
echo $line

find . -name $line -type d -exec rm -r {} +
 
if [ $? -eq 0 ];
then
echo "Deleted "
else
echo " No such file"
fi
done</tmp/deletelog.txt


    echo " Deleted Files in $PWD"



  echo "**********Job Completed in $host *************"



sleep 10 

cd ~/script






