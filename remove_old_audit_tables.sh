#!bin/bash
G_MD5SUM_ORG_FILE=""
G_MD5SUM_S3_FILE=""
G_MYSQL_USERNAME="dbadmin"
G_PASSWORD="Leanon@129"
G_CLIENT="app2"
G_S3_BUCKET="s3://backup-${G_CLIENT}.mysignaturebook.com/OLD_AUDIT_TABLES_DUMP/"

G_ZIP_FILENAME="${G_CLIENT}_dump_audit_old.tar.gz"
rm -rf dump_audit_old
rm -rf *audit*old.sql
mkdir dump_audit_old

echo "=============DB SIZE BEFORE RUNNING THIS SCRIPT==================================="
mysql -u$G_MYSQL_USERNAME -p$G_PASSWORD -N information_schema -e "SELECT table_schema AS \"Database\", ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS \"Size (MB)\" FROM information_schema.TABLES GROUP BY table_schema"
echo "=================================================================================="

echo "G_PASSWORD=Leanon@129" > oldTablesBackup.sh
mysql -u$G_MYSQL_USERNAME -p$G_PASSWORD -N information_schema -e "select concat('mysqldump -u$G_MYSQL_USERNAME' ,' -p$G_PASSWORD msb ',table_name, ' > ./dump_audit_old/','$G_CLIENT' ,'_' ,table_name, '.sql') from tables where table_schema = 'msb' and table_name like '%audit_old%'" >> oldTablesBackup.sh
l_line_count=`cat oldTablesBackup.sh | wc -l`
if [[ ${l_line_count} -gt 1 ]]; then
sh oldTablesBackup.sh
else
echo "No tables found with string ===[audit_old]==="
exit 0;
fi

echo -e "\n\n"
echo "=============PLEASE CHECK IF THERE IS ANY FILE WITH ZERO BYTES======================"
ls -ltr ./dump_audit_old/
echo "=================================================================================="
echo -e "\n\n"
read -p "Press any key to continue or CTRL+C to exit"
tar -czvf ${G_ZIP_FILENAME} dump_audit_old
G_MD5SUM_ORG_FILE=($(md5sum ${G_ZIP_FILENAME}))
echo -e "\n\n"
echo -e "=============EXECUTE BELOW COMMAND MANUALLY=======================================\n"
echo "/bin/flock -n /tmp/s3lock.lck /bin/s3cmd put --server-side-encryption --storage-class=STANDARD_IA /root/${G_ZIP_FILENAME} ${G_S3_BUCKET}"
echo "=================================================================================="

echo -e "\n\n"
read -p "Press any key to continue or CTRL+C to exit"
G_MD5SUM_S3_FILE=`s3cmd ls --list-md5 ${G_S3_BUCKET}${G_ZIP_FILENAME} | awk '{print $4}'`

echo "====G_MD5SUM_ORG_FILE===${G_MD5SUM_ORG_FILE}"
echo "====G_MD5SUM_S3_FILE===${G_MD5SUM_S3_FILE}"

if [[ ${G_MD5SUM_ORG_FILE} == ${G_MD5SUM_S3_FILE} ]]; then
echo "MD5SUM Matches"
else
echo "MD5SUM match failed. Exiting..."
exit 1;
fi

read -p "Going to drop tables .Press any key to continue or CTRL+C to exit"

echo "G_PASSWORD=Leanon129" > dropOldTablesBackup.sh
mysql -u$G_MYSQL_USERNAME -p$G_PASSWORD -N information_schema -e "select concat('mysql -u$G_MYSQL_USERNAME' ,' -p$G_PASSWORD msb -e \"drop table ',table_name,'\"') from tables where table_schema = 'msb' and table_name like '%audit_old%'" >> dropOldTablesBackup.sh
sh dropOldTablesBackup.sh
rm -rf oldTablesBackup.sh dump_audit_old dropOldTablesBackup.sh ${G_ZIP_FILENAME}

echo "=============DB SIZE AFTER RUNNING THIS SCRIPT==================================="
mysql -u$G_MYSQL_USERNAME -p$G_PASSWORD -N information_schema -e "SELECT table_schema AS \"Database\", ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS \"Size (MB)\" FROM information_schema.TABLES GROUP BY table_schema"
echo "=================================================================================="