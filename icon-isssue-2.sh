#!/bin/bash
filename=$1

rm -rf /home/centos/tmp/*
rm -rf /home/centos/success.txt
rm -rf /home/centos/failed.txt

destination=/home/centos/tmp/
while read -r line; do
myfile="$line"
cp --parents -r "$myfile" $destination

RESULT=$?
if [ $RESULT -eq 0 ]; then
  
echo success
  echo "success $line" >> /home/centos/success.txt
else
  echo failed
  echo "failed $line" >> /home/centos/failed.txt
fi
done < $filename



#!/bin/bash

cd /nfs/msb/tmp/pdfs

while read -r line; do
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
done < /home/servsupport/d1703_1.txt







find ./f1b62d1a-bf8a-46fa-b9aa-16d01db79e8d/ -name "*.*" >> /home/servsupport/d1703.txt

cd /home/servsupport/tmp-doc-icon
cp --parents -r "f1b62d1a-bf8a-46fa-b9aa-16d01db79e8d/693243d6-b260-4b64-81c4-e6a0e3bf1402/ea45b7ec-1ff1-429a-a56f-e815a7c36b30/TEST DOCUMENT.pdf" /nfs/msb/tmp/pdfs/

ls -ltr "/nfs/msb/tmp/pdfs/f1b62d1a-bf8a-46fa-b9aa-16d01db79e8d/693243d6-b260-4b64-81c4-e6a0e3bf1402/ea45b7ec-1ff1-429a-a56f-e815a7c36b30/TEST DOCUMENT.pdf"

./f1b62d1a-bf8a-46fa-b9aa-16d01db79e8d/693243d6-b260-4b64-81c4-e6a0e3bf1402/ea45b7ec-1ff1-429a-a56f-e815a7c36b30/TEST DOCUMENT.pdf



