#!bin/bash
G_MD5SUM_ORG_FILE=""
G_MD5SUM_S3_FILE=""
G_MYSQL_USERNAME="dbadmin"
G_CLIENT="esign.roche"
G_PASSWORD="Leanon@129"
G_AUDIT_TABLE_LIST="'document_audit','epak_audit','epak_document_audit','user_audit','user_preference_audit','user_tenant_audit','usercertificate_audit'"
G_S3_BUCKET="s3://backup-${G_CLIENT}.com/AUDIT_TABLES_DUMP/"
G_DATE=`date +'%d%m%Y%H%M%S'`
G_ZIP_FILENAME="dump_archive_tables-${G_DATE}.tar.gz"
rm -rf dump_audit_tables
mkdir dump_audit_tables

echo "=============DB SIZE BEFORE RUNNING THIS SCRIPT==================================="
mysql -u$G_MYSQL_USERNAME -p$G_PASSWORD -N information_schema -e "SELECT table_schema AS \"Database\", ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS \"Size (MB)\" FROM information_schema.TABLES GROUP BY table_schema"
echo "=================================================================================="

echo "G_PASSWORD=Leanon@129" > auditTablesBackup.sh
mysql -u$G_MYSQL_USERNAME -p$G_PASSWORD -N information_schema -e "select concat('mysqldump -u$G_MYSQL_USERNAME' ,' -p$G_PASSWORD msb ',table_name, ' > ./dump_audit_tables/','$G_CLIENT' ,'_' ,table_name, '.sql') from tables where table_schema = 'msb' and table_name in ($G_AUDIT_TABLE_LIST)" >> auditTablesBackup.sh
#sh auditTablesBackup.sh


echo "G_PASSWORD=Leanon129" > truncateAuditTables.sh
mysql -u$G_MYSQL_USERNAME -p$G_PASSWORD -N information_schema -e "select concat('mysql -u$G_MYSQL_USERNAME' ,' -p$G_PASSWORD msb -e \"truncate table ',table_name,'\"') from tables where table_schema = 'msb' and table_name in ($G_AUDIT_TABLE_LIST)" >> truncateAuditTables.sh
#sh truncateAuditTables.sh


echo -e "\n\n"
echo "=============PLEASE CHECK IF THERE IS ANY FILE WITH ZERO BYTES======================"
ls -ltr ./dump_audit_tables/
echo "=================================================================================="
echo -e "\n\n"
read -p "Press any key to continue or CTRL+C to exit"
tar -czvf ${G_ZIP_FILENAME} dump_audit_tables
G_MD5SUM_ORG_FILE=($(md5sum ${G_ZIP_FILENAME}))
echo -e "\n\n"
echo "=============EXECUTE BELOW COMMAND MANUALLY======================================="
echo "/bin/flock -n /tmp/s3lock.lck /bin/s3cmd put --server-side-encryption --storage-class=STANDARD_IA ${G_ZIP_FILENAME} ${G_S3_BUCKET}"
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

#rm -rf auditTablesBackup.sh ${G_ZIP_FILENAME} dump_audit_tables

echo "=============DB SIZE AFTER RUNNING THIS SCRIPT==================================="
mysql -u$G_MYSQL_USERNAME -p$G_PASSWORD -N information_schema -e "SELECT table_schema AS \"Database\", ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS \"Size (MB)\" FROM information_schema.TABLES GROUP BY table_schema"
echo "=================================================================================="




