#!/bin/bash

cd ./upload/

echo "Get config file"
s3cmd -rf get s3://icon.sftp/config.json
 
for str in `s3cmd ls --list-md5 s3://icon.sftp/upload/ | grep ".pdf" | awk '{print $4"|"$5}'`
do
fullPath=`echo ${str} | awk -F'|' '{print $2}'`
filename="${fullPath##*/}"  # get filename

s3cmd -rf get s3://icon.sftp/upload/${filename} 
md5sumSource=`echo ${str} | awk -F'|' '{print $1}'`
md5sumDestination=($(md5sum ${filename}))

echo "Compare MD5 Sum md5sumSource=${md5sumSource} md5sumDestination=${md5sumDestination} "
if [[ "${md5sumSource}" == "${md5sumDestination}" ]]; then
 echo "Moving ${filename} to processed folder on S3 Bucket"
 s3cmd mv s3://icon.sftp/upload/${filename} s3://icon.sftp/processed/${filename}
else
 echo "MD5SUM doesnot match for file ${filename}"
 echo "Moving ${filename} to Error Folder on S3 Bucket"
 s3cmd mv s3://icon.sftp/upload/${filename} s3://icon.sftp/error/${filename}

fi
done

#s3cmd mv s3://icon.sftp/error/oversize_pdf_test_0.pdf  s3://icon.sftp/upload/oversize_pdf_test_0.pdf &