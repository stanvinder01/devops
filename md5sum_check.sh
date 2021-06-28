#!/bin/bash
i=0
rm -rf /home/servsupport/md5yes.txt
rm -rf /home/servsupport/md5no.txt
while read -r line; do
   ((i=i+1))
    echo "i: $i"
	ebs_md5sum=$(echo $line | awk '{print $1}')
    ebs_fp=$(echo $line | awk '{print substr($0,2,length($0)-2)}')

echo $ebs_fp
md5=($(md5sum "$ebs_fp"))
if [ -f "$ebs_fp" ]; then
   echo "md5 YES $md5" >> /home/servsupport/md5yes.txt
else
   echo "md5 NO $md5" >> /home/servsupport/md5no.txt
fi

done < /home/servsupport/fpth-masaood.csv


echo $md5
echo $md5 >> /var/lib/mysql-files/md5.txt

cat fpth-masaood.csv | awk '{print substr($0,2,length($0)-1)}'

1. useruuid, tile from SFTP(masaood) --> md5sum of all docs
2. Filepath from masaood db 
3. table dump --> md5sum of all files found in the filepath
4.  compare masaood md5sum=== nfs md5sum

#!/bin/bash

while read -r line; do
ebs_md5sum=$(echo $line | awk '{print $1}')
echo $ebs_md5sum
md5sum_fp=$(grep $ebs_md5sum md5yes.txt | wc -l)
if [ $md5sum_fp -eq 1 ]; then
echo "$line" >> /home/servsupport/md5found.txt
else
echo "$line" >> /home/servsupport/md5found.txt
fi
done < /home/servsupport/md5sum-data.csv