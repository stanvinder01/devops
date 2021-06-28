#!/bin/bash
i=0
rm -rf /home/servsupport/md5sumno_2.txt
rm -rf /home/servsupport/md5sumyes_2.txt
#rm -rf /home/servsupport/md5nomatch.txt
#rm -rf /home/servsupport/md5match.txt
cd /nfs/msb/tmp/pdfs
while read -r line; do
((i=i+1))
echo "i: $i"
ebs_md5sum=$(echo $line | awk '{print $1}')
ebs_fp=$(echo $line | awk '{print "/nfs/msb/tmp/pdfs/"substr($0,36)}')
#echo "=====$ebs_md5sum=======$ebs_fp======="
#echo $ebs_fp
if [ -f "$ebs_fp" ]; then
echo "md5sum yes $ebs_fp" >> /home/servsupport/md5sumyes_2.txt
#md5=($(md5sum "$ebs_fp"))
#echo "line -----$md5"
else
echo "md5sum no $ebs_fp" >> /home/servsupport/md5sumno_2.txt
fi
done < /home/servsupport/md5sum-data_2.csv

cat md5sum-data_2.csv | head -n 10 | awk '{print substr($0,37)}'

if [ "$ebs_md5sum" == "$md5" ]; then
echo "md5 match $ebs_fp" >> /home/servsupport/md5match.txt
else 
echo "md5 nomatch $ebs_fp" >> /home/servsupport/md5nomatch.txt
fi


find ./ -type f -newermt "2 Mar 2021 00:00:00" > /home/centos/data.csv

md5sumyes
12258 

md5match.txt
10692

md5nomatch.txt
1566 ?

md5sumno.txt
3117 ?

data.csv
15374

data.csv = md5sumyes + md5sumno

md5sumyes = md5nomatch + md5match


/nfs/msb/tmp/pdfs/f1b62d1a-bf8a-46fa-b9aa-16d01db79e8d/dda2f37b-4337-4a8b-a31b-b582c1fc5931/5231a765-df59-404e-abbc-b72d96d896e5/Original_B7541007_SSU CR     A Transition Checklist v4.0 05Jan2021_1086_RO_02Mar2021



echo $md5


echo $line
if [ -f "$line" ]; then
echo "y" >> /home/servsupport/y.txt
else
echo "n" >> /home/servsupport/n.txt
src1="/home/servsupport/tmp-doc-icon"
cd $src1
cp --parents -r "$line" /nfs/msb/tmp/pdfs/ 
cd /nfs/msb/tmp/pdfs/
if [ -f "$line" ]; then
echo "after copy yes $line" >> /home/servsupport/afteryes.txt
else
echo "after copy no $line" >> /home/servsupport/afterno.txt
fi
fi

cat /home/servsupport/md5sum-data.csv | awk '{print $1}'

ls -ltr "/nfs/msb/tmp/pdfs/f1b62d1a-bf8a-46fa-b9aa-16d01db79e8d/46c14b14-46b2-4d74-99f3-c38f1ea51696/112e974d-e670-4f36-873d-f113326c5eb6/Flat_MT-7117-G02_0004-00081_CDP Transition Checklist_Mayes_02Mar2021.pdf"