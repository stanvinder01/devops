#!/bin/bash
date  > /root/maillog_init0.txt
while(($#))
        do
        object=$1
                rm -f /tmp/backup/db/M*
                rm -f /tmp/1.txt
                rm -f /tmp/2.txt
                mv /var/lib/mysql-files/$1-* /tmp/reports/
        bucket=$(echo backup-$1)
        obpath=$(echo $bucket/Databases/)
        file=$(s3cmd ls s3://$obpath --recursive | sort | tail -n 1 | awk '{for(i=4;i<=NF;++i)print $i}')
        echo File: $file
        filedate=$(echo $file | cut -d '/' -f5 )
        echo Filedate: $filedate
        path=$(echo "\"$file\"")
        download=$(echo /bin/s3cmd sync $path /tmp/backup/db/)
                echo $download > /scripts/dbr/file.sh
                sh /scripts/dbr/file.sh
        fdir=$(echo /tmp/backup/db/)
        fname=$(ls -t $fdir| head -n1)
        pdir=$(echo /backup/db/)
                rm -rf $pdir*
                cp $fdir$fname $pdir
                psize=$(du $pdir$fname |  awk '{ print $1 }')
                gzip -d $pdir$fname
                pfname=$(ls -t $pdir | head -n1)
                csize=$(du $pdir$pfname |  awk '{ print $1 }' )
        if [ $csize -lt $psize ]
        then
                /bin/sh /scripts/email/dbr/dbr/databasebackup-failure.sh $object $path
                echo databasebackup-failure.sh
        else
                echo INFO: Uncompression successful
               mysql -A -udbadmin -pLeanon@129 --default-character-set=utf8 -e "drop database msb; create database msb; use msb; source $pdir$pfname;  show tables; select found_rows() into outfile '/var/lib/mysql-files/1.txt';"
#               mysql -A -udbadmin -pLeanon@129 --default-character-set=utf8 -e "use msb; show tables; select found_rows() into outfile '/var/lib/mysql-files/1.txt';"
#               localuptime=$(mysql -A -udbadmin -pLeanon@129  -e "drop database msb; create database msbtest; use msbtest; source $pdir$pfname; SELECT MAX(UPDATE_TIME) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() ;" | grep -v "\----" | grep -v "MAX(UPDATE_TIME)")
                localsize=$(mysql -udbadmin -pLeanon@129 -e "SELECT table_schema, sum(data_length + index_length)/1024 FROM information_schema.TABLES WHERE table_schema='msb' GROUP BY table_schema;" | grep -v "\----" | grep -v "table" | awk '{ print $2}')
                mv /var/lib/mysql-files/1.txt /tmp/
                ntb=$(cat /tmp/1.txt)
                echo $object
                echo "file1:"$ntb
                case "$object" in
                "esign.roche.com")mysql -h10.0.1.35 -ureadonly -preadonly -e "use msb; show tables;  select found_rows()"> /var/lib/mysql-files/2.txt
                hostsize=$(mysql -h10.0.1.35 -ureadonly -preadonly -e "SELECT table_schema, sum(data_length + index_length)/1024 FROM information_schema.TABLES WHERE table_schema='msb' GROUP BY table_schema;" | grep -v "\----" | grep -v "table" | awk '{ print $2}')
                if [[ $(date +%d) -eq 01 ]] ; then
                                mysql -A -udbadmin -pLeanon@129 -e " use msb; source /scripts/report_3-12.sql;"
                                mv /var/lib/mysql-files/Epak-MonthlyCnt.csv /var/lib/mysql-files/$1-Epak-MonthlyCnt.csv
                                mv /var/lib/mysql-files/UserRole-MonthlyCnt.csv /var/lib/mysql-files/$1-UserRole-MonthlyCnt.csv
                                mv /var/lib/mysql-files/UserAct-MonthlyCnt.csv /var/lib/mysql-files/$1-UserAct-MonthlyCnt.csv
                                /bin/bash /scripts/email/report.sh $1 "$filedate"
                                mv /var/lib/mysql-files/$1-* /tmp/reports/
                        exit
                        fi
                ;;
                "isign.gsk.com")mysql -h10.0.1.52 -ureadonly -preadonly -e "use msb; show tables;  select found_rows()"> /var/lib/mysql-files/2.txt
                hostsize=$(mysql -h10.0.1.52 -ureadonly -preadonly -e "SELECT table_schema, sum(data_length + index_length)/1024 FROM
information_schema.TABLES WHERE table_schema='msb' GROUP BY table_schema;" | grep -v "\----" | grep -v "table" | awk '{ print $2}')
                if [[ $(date +%d) -eq 01 ]] ; then
                        mysql -A -udbadmin -pLeanon@129 -e " use msb; source /scripts/report_3-9.sql;"
                        mv /var/lib/mysql-files/UserList_login.csv /var/lib/mysql-files/$1-UserList_login.csv
                        mv /var/lib/mysql-files/userList-Login-Epak_Count.csv /var/lib/mysql-files/$1-userList-Login-Epak_Count.csv
                        /bin/bash /scripts/email/report.sh $1 "$filedate"
                        mv /var/lib/mysql-files/$1-* /tmp/reports/
                        exit
                        fi
                ;;
                "apollo.mysignaturebook.com") mysql -h10.0.1.15 -ureadonly -preadonly -e "use msb; show tables;  select found_rows()"> /var/lib/mysql-files/2.txt
                hostsize=$(mysql -h10.0.1.15 -ureadonly -preadonly -e "SELECT table_schema, sum(data_length + index_length)/1024 FROM information_schema.TABLES WHERE table_schema='msb' GROUP BY table_schema;" | grep -v "\----" | grep -v "table" | awk '{ print $2}')
                if [[ $(date +%d) -eq 01 ]] ; then
                                mysql -A -udbadmin -pLeanon@129 -e " use msb; source /scripts/report_3-12.sql;"
                                mv /var/lib/mysql-files/Epak-MonthlyCnt.csv /var/lib/mysql-files/$1-Epak-MonthlyCnt.csv
                                mv /var/lib/mysql-files/UserRole-MonthlyCnt.csv /var/lib/mysql-files/$1-UserRole-MonthlyCnt.csv
                                mv /var/lib/mysql-files/UserAct-MonthlyCnt.csv /var/lib/mysql-files/$1-UserAct-MonthlyCnt.csv
                                /bin/bash /scripts/email/report.sh $1 "$filedate"
                                mv /var/lib/mysql-files/$1-* /tmp/reports/
                        exit
                        fi
                ;;
                "pfizer.mysignaturebook.com") mysql -h10.0.1.43 -ureadonly -preadonly -e "use msb; show tables;  select found_rows()"> /var/lib/mysql-files/2.txt
                hostsize=$(mysql -h10.0.1.43 -ureadonly -preadonly -e "SELECT table_schema, sum(data_length + index_length)/1024 FROM information_schema.TABLES WHERE table_schema='msb' GROUP BY table_schema;" | grep -v "\----" | grep -v "table" | awk '{ print $2}')
                if [[ $(date +%d) -eq 01 ]] ; then
                                mysql -A -udbadmin -pLeanon@129 -e " use msb; source /scripts/report_3-12.sql;"
                                mv /var/lib/mysql-files/Epak-MonthlyCnt.csv /var/lib/mysql-files/$1-Epak-MonthlyCnt.csv
                                mv /var/lib/mysql-files/UserRole-MonthlyCnt.csv /var/lib/mysql-files/$1-UserRole-MonthlyCnt.csv
                                mv /var/lib/mysql-files/UserAct-MonthlyCnt.csv /var/lib/mysql-files/$1-UserAct-MonthlyCnt.csv
                                /bin/bash /scripts/email/report.sh $1 "$filedate"
                                mv /var/lib/mysql-files/$1-* /tmp/reports/
                        exit
                        fi
                ;;
                "app.mysignaturebook.com") mysql -h11.0.1.15 -ureadonly -preadonly -e "use msb; show tables;  select found_rows()"> /var/lib/mysql-files/2.txt
                hostsize=$(mysql -h11.0.1.15 -ureadonly -preadonly -e "SELECT table_schema, sum(data_length + index_length)/1024 FROM information_schema.TABLES WHERE table_schema='msb' GROUP BY table_schema;" | grep -v "\----" | grep -v "table" | awk '{ print $2}')
                if [[ $(date +%d) -eq 01 ]] ; then
                                mysql -A -udbadmin -pLeanon@129 -e " use msb; source /scripts/report_3-12.sql;"
                                mv /var/lib/mysql-files/Epak-MonthlyCnt.csv /var/lib/mysql-files/$1-Epak-MonthlyCnt.csv
                                mv /var/lib/mysql-files/UserRole-MonthlyCnt.csv /var/lib/mysql-files/$1-UserRole-MonthlyCnt.csv
                                mv /var/lib/mysql-files/UserAct-MonthlyCnt.csv /var/lib/mysql-files/$1-UserAct-MonthlyCnt.csv
                                /bin/bash /scripts/email/report.sh $1 "$filedate"
                                mv /var/lib/mysql-files/$1-* /tmp/reports/
                        exit
                        fi
                ;;
                "app2.mysignaturebook.com") mysql -h40.0.1.105 -ureadonly -preadonly -e "use msb; show tables;  select found_rows()"> /var/lib/mysql-files/2.txt
                hostsize=$(mysql -h40.0.1.105 -ureadonly -preadonly -e "SELECT table_schema, sum(data_length + index_length)/1024 FROM information_schema.TABLES WHERE table_schema='msb
' GROUP BY table_schema;" | grep -v "\----" | grep -v "table" | awk '{ print $2}')
                if [[ $(date +%d) -eq 01 ]] ; then
                                mysql -A -udbadmin -pLeanon@129 -e " use msb; source /scripts/report_3-12.sql;"
                                mv /var/lib/mysql-files/Epak-MonthlyCnt.csv /var/lib/mysql-files/$1-Epak-MonthlyCnt.csv
                                mv /var/lib/mysql-files/UserRole-MonthlyCnt.csv /var/lib/mysql-files/$1-UserRole-MonthlyCnt.csv
                                mv /var/lib/mysql-files/UserAct-MonthlyCnt.csv /var/lib/mysql-files/$1-UserAct-MonthlyCnt.csv
                                /bin/bash /scripts/email/report.sh $1 "$filedate"
                                mv /var/lib/mysql-files/$1-* /tmp/reports/
                        exit
                        fi
                ;;
                "atln.mysignaturebook.com") mysql -h10.0.1.25 -ureadonly -preadonly -e "use msb; show tables;  select found_rows()"> /var/lib/mysql-files/2.txt
                hostsize=$(mysql -h10.0.1.25 -ureadonly -preadonly -e "SELECT table_schema, sum(data_length + index_length)/1024 FROM
information_schema.TABLES WHERE table_schema='msb' GROUP BY table_schema;" | grep -v "\----" | grep -v "table" | awk '{ print $2}')
                if [[ $(date +%d) -eq 01 ]] ; then
                        mysql -A -udbadmin -pLeanon@129 -e " use msb; source /scripts/report_3-9.sql;"
                        mv /var/lib/mysql-files/UserList_login.csv /var/lib/mysql-files/$1-UserList_login.csv
                        mv /var/lib/mysql-files/userList-Login-Epak_Count.csv /var/lib/mysql-files/$1-userList-Login-Epak_Count.csv
                        /bin/bash /scripts/email/report.sh $1 "$filedate"
                        mv /var/lib/mysql-files/$1-* /tmp/reports/
                        exit
                        fi
                ;;
                "icon.mysignaturebook.com")
                echo "I was here in Icon"
                mysql -h11.0.1.43 -ureadonly -preadonly -e "use msb; show tables;  select found_rows()" > /var/lib/mysql-files/2.txt
                hostsize=$(mysql -h11.0.1.43 -ureadonly -preadonly -e "SELECT table_schema, sum(data_length + index_length)/1024 FROM information_schema.TABLES WHERE table_schema='msb' GROUP BY table_schema;" | grep -v "\----" | grep -v "table" | awk '{ print $2}')
                        if [[ $(date +%d) -eq 01 ]] ; then
                                echo "I was here as well"
                                mysql -A -udbadmin -pLeanon@129 -e " use msb; source /scripts/report_3-12.sql;"
                                mv /var/lib/mysql-files/Epak-MonthlyCnt.csv /var/lib/mysql-files/$1-Epak-MonthlyCnt.csv
                                mv /var/lib/mysql-files/UserRole-MonthlyCnt.csv /var/lib/mysql-files/$1-UserRole-MonthlyCnt.csv
                                mv /var/lib/mysql-files/UserAct-MonthlyCnt.csv /var/lib/mysql-files/$1-UserAct-MonthlyCnt.csv
                                /bin/bash /scripts/email/report.sh $1 "$filedate"
                                mv /var/lib/mysql-files/$1-* /tmp/reports/
                        exit
                        fi
                        mv /var/lib/mysql-files/$1-* /tmp/reports
                        if [[ $(date +%u) -eq 7 ]] ; then
                        mysql -A -udbadmin -pLeanon@129 -e " use msb; source /scripts/icon_weekly_report/weekly_IconCRA.sql;"
                        /bin/bash /scripts/email/weekly_icon_report.sh _report.csv "$filedate"
                        mv /var/lib/mysql-files/*_report.csv /tmp/reports/IconWeekly/
                        exit
                        fi
                ;;
#               echo "I am in "$object
                esac
#               mysql -h10.0.1.15 -ureadonly -preadonly -e "use msb; show tables;  select found_rows()"> /var/lib/mysql-files/2.txt
#               hostsize=$(mysql -h10.0.1.15 -ureadonly -preadonly -e "SELECT table_schema, sum(data_length + index_length)/1024 FROM information_schema.TABLES WHERE table_schema='msb' GROUP BY table_schema;" | grep -v "\----" | grep -v "table" | awk '{ print $2}')
                cat /var/lib/mysql-files/2.txt | tail -n 1
                mv /var/lib/mysql-files/2.txt /tmp/
                nth=$(cat /tmp/2.txt | tail -n 1)
                echo "file2:"$nth
                if [ $ntb -eq $nth ]
                        then
                                /bin/sh /scripts/email/dbr/dbr/dbrestorationemail-success.sh $ntb $nth $object $localsize $hostsize "$file"
                       else
                                /bin/sh /scripts/email/dbr/dbr/dbrestorationemail-failure.sh $ntb $nth $object $localsize $hostsize "$file"
               fi
fi
shift
done
sleep 5s
/sbin/init 0
 
#date >> /root/maillog_init0.txt
#date >> /root/maillog_init0.txt
cat /var/log/maillog | grep itsupport | tail -n 50 >> /root/maillog_init0.txt

