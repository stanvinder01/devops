#!bin/bash
##This script will
G_MYSQL_USERNAME="dbadmin"
G_CLIENT="masaood"
G_PASSWORD="Leanon@129"
G_AUDIT_TABLE_LIST="'document_audit_detail','epak_audit_detail','epak_document_audit_detail','user_audit_detail','user_preference_audit_detail','user_tenant_audit_detail','usercertificate_audit_detail','document_audit','epak_audit','epak_document_audit','user_audit','user_preference_audit','user_tenant_audit','usercertificate_audit'"
G_ARC_TABLE_LIST="'arc_document_audit_detail','arc_epak_audit_detail','arc_epak_document_audit_detail','arc_user_audit_detail','arc_user_preference_audit_detail','arc_user_tenant_audit_detail','arc_usercertificate_audit_detail'"
G_ZIP_FILENAME="${G_CLIENT}_dump_archive_tables.tar.gz"
G_S3_BUCKET="s3://backup-${G_CLIENT}.mysignaturebook.com/OLD_AUDIT_TABLES_DUMP/"
rm -rf dump_archive_tables
mkdir dump_archive_tables

echo "G_PASSWORD=Leanon129" > dropArcTables.sh
mysql -u$G_MYSQL_USERNAME -p$G_PASSWORD -N information_schema -e "select concat('mysql -u$G_MYSQL_USERNAME' ,' -p$G_PASSWORD msb -e \"drop1 table ',table_name,'\"') from tables where table_schema = 'msb' and table_name in ($G_ARC_TABLE_LIST)" >> dropArcTables.sh
#sh dropArcTables.sh


echo "G_PASSWORD=Leanon129" > createArcTables.sh
mysql -u$G_MYSQL_USERNAME -p$G_PASSWORD -N information_schema -e "select concat('mysql -u$G_MYSQL_USERNAME' ,' -p$G_PASSWORD msb -e \"create1 table arc_',table_name,' as select * from ', table_name,'\"') from tables where table_schema = 'msb' and  table_name in ($G_AUDIT_TABLE_LIST)" >> createArcTables.sh
#sh createArcTables.sh


echo "G_PASSWORD=Leanon129" > truncateAuditTables.sh
mysql -u$G_MYSQL_USERNAME -p$G_PASSWORD -N information_schema -e "select concat('mysql -u$G_MYSQL_USERNAME' ,' -p$G_PASSWORD msb -e \"truncate1 table ',table_name,'\"') from tables where table_schema = 'msb' and table_name in ($G_AUDIT_TABLE_LIST)" >> truncateAuditTables.sh
#sh truncateAuditTables.sh


echo "G_PASSWORD=Leanon@129" > archiveTablesBackup.sh
mysql -u$G_MYSQL_USERNAME -p$G_PASSWORD -N information_schema -e "select concat('mysqldump -u$G_MYSQL_USERNAME' ,' -p$G_PASSWORD msb ',table_name, ' > ./dump_archive_tables/','$G_CLIENT' ,'_' ,table_name, '.sql') from tables where table_schema = 'msb' and table_name in ($G_ARC_TABLE_LIST)" >> archiveTablesBackup.sh
#sh archiveTablesBackup.sh


# echo -e "\n\n"
# echo "=============PLEASE CHECK IF THERE IS ANY FILE WITH ZERO BYTES======================"
# ls -ltr ./dump_archive_tables/
# echo "=================================================================================="
# echo -e "\n\n"
# read -p "Press any key to continue or CTRL+C to exit"
# tar -czvf ${G_ZIP_FILENAME} dump_archive_tables
# echo -e "\n\n"
# echo "=============EXECUTE BELOW COMMAND MANUALLY======================================="
# echo "/bin/flock -n /tmp/s3lock.lck /bin/s3cmd put --server-side-encryption --storage-class=STANDARD_IA  ${G_ZIP_FILENAME} ${G_S3_BUCKET}"
# echo "=================================================================================="

#rm -rf archiveTablesBackup.sh ${G_ZIP_FILENAME} dump_archive_tables




