#!/bin/bash

rm -rf /home/servsupport/yes1.txt
rm -rf /home/servsupport/no1.txt

cd /nfs/msb/tmp/pdfs/

while read line; do
    echo "Filename is $line"
	myfile="$line"
	echo "MYFILE is $myfile"
if [ -f "$myfile" ]; then
   echo "YES $myfile" >> /home/servsupport/yes1.txt
else
   echo "NO $myfile" >> /home/servsupport/no1.txt
fi
done < /home/servsupport/nocp.txt

if [ ! -f "$file" ]


| /nfs/msb/tmp/pdfs//f1b62d1a-bf8a-46fa-b9aa-16d01db79e8d/7ca1d88e-6b40-49ef-b43c-d6f545e60576//139f5aa2-a892-44d4-bb05-296206199b80/21CFR - Electronic Signature form.pdf           |
| /nfs/msb/tmp/pdfs//f1b62d1a-bf8a-46fa-b9aa-16d01db79e8d/7ca1d88e-6b40-49ef-b43c-d6f545e60576//f6acfb7d-f13c-4e27-977e-acf5f735b27a/Employment Contract - Chase Ramos.pdf           |
| /nfs/msb/tmp/pdfs//f1b62d1a-bf8a-46fa-b9aa-16d01db79e8d/584c89fe-150c-478e-80ca-79f446803c70//836bcf5b-7137-4cbf-a986-514e4fa85880/190479_Deviation_1_Prep_documentation_error.pdf |

#!/bin/bash

cd /nfs/msb/tmp/pdfs/

line="/nfs/msb/tmp/pdfs/f1b62d1a-bf8a-46fa-b9aa-16d01db79e8d/7ca1d88e-6b40-49ef-b43c-d6f545e60576/139f5aa2-a892-44d4-bb05-296206199b80/21CFR - Electronic Signature form.pdf"
    echo "Filename is $line"
if test -f "$line"; then
    echo "YES $line"
else
    echo "NO $line"
fi

line="/nfs/msb/tmp/pdfs//f1b62d1a-bf8a-46fa-b9aa-16d01db79e8d/7ca1d88e-6b40-49ef-b43c-d6f545e60576//f6acfb7d-f13c-4e27-977e-acf5f735b27a/Employment Contract - Chase Ramos.pdf"
    echo "Filename is $line"
if test -f "$line"; then
    echo "YES $line"
else
    echo "NO $line"
fi

line=/nfs/msb/tmp/pdfs//f1b62d1a-bf8a-46fa-b9aa-16d01db79e8d/584c89fe-150c-478e-80ca-79f446803c70//836bcf5b-7137-4cbf-a986-514e4fa85880/190479_Deviation_1_Prep_documentation_error.pdf
    echo "Filename is $line"
if test -f "$line"; then
    echo "YES $line"
else
    echo "NO $line"
fi



./f1b62d1a-bf8a-46fa-b9aa-16d01db79e8d/584c89fe-150c-478e-80ca-79f446803c70/836bcf5b-7137-4cbf-a986-514e4fa85880/Original_190479_Deviation_1_Prep_documentation_error.pdf
./f1b62d1a-bf8a-46fa-b9aa-16d01db79e8d/584c89fe-150c-478e-80ca-79f446803c70/836bcf5b-7137-4cbf-a986-514e4fa85880/190479_Deviation_1_Prep_documentation_error.pdf
./f1b62d1a-bf8a-46fa-b9aa-16d01db79e8d/584c89fe-150c-478e-80ca-79f446803c70/836bcf5b-7137-4cbf-a986-514e4fa85880/Flat_190479_Deviation_1_Prep_documentation_error.pdf


#!/bin/bash

rm -rf /home/servsupport/yes1.txt
rm -rf /home/servsupport/no1.txt

cd /nfs/msb/tmp/pdfs/

while read line; do
    echo "Filename is $line"
	myfile="$line"
	echo "MYFILE is $myfile"
if [ -f "$myfile" ]; then
   echo "YES $myfile" >> /home/servsupport/yes1.txt
else
   echo "NO $myfile" >> /home/servsupport/no1.txt
fi
done < /home/servsupport/nocp.txt


#!/bin/bash 

rm -rf /home/servsupport/success.txt
rm -rf /home/servsupport/failed.txt 
p="/nfs/msb/tmp/pdfs"
cd $p

while read line; do
echo "Filename is $line"

ls $line 2> /dev/null
RESULT=$?
if [ $RESULT -eq 0 ]; then
  echo success
  echo "success $line" >> /home/servsupport/success.txt
else
  echo failed
  echo "failed $line" >> /home/servsupport/failed.txt
fi

done < /home/servsupport/nocp.txt


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