grep / unique_userid_notfound.txt >> test.txt


cat md5notfound.txt | awk -F'./' '{print $2}' | awk '{print substr($2,0,36)}'

cat md5notfound.txt | awk -F'./' '{print $2}' | sort| uniq -c | awk '{print substr($2,1,36)}'

cat useruuid_notfound.txt | awk '{print substr($0,1,36)}'| sort | uniq -c

grep '\\' useruuid_notfound.txt | awk -F'\' '{print $1}'

cat useruuid_notfound.txt | awk '{print substr($0,1,36)}'| sort | uniq | grep '\\' useruuid_notfound.txt | awk -F'\' '{print $1}'

cat doc_notfound.txt | awk '{print "select email from user where uuid in('"substr($0,3,35)"',"}'


cat md5found.txt | awk -F'./' '{print $2}' | sort| uniq -c | awk '{print substr($2,1,36)} >> useruuid_found.txt

cat md5found.txt | awk -F'./' '{print $2}' >> doc_found.txt

cat user-not-found2.txt |awk '{print substr($0,2,35)}'|sort |uniq -c >> tan1.txt

cat tan1.txt |awk '{print "\x27"substr($0,9,36)"\x27,"}'


cat user-not-found2.txt |awk '{print substr($0,2,37)}' | sort | uniq -c


cat md5found.txt |awk '{print $2}'| sort | uniq | wc -l

cat md5found.txt |awk '{print substr($9,5)}'| sort | uniq | wc -l

cat user-not-found2.txt |awk '{print "\x27"substr($0,3,36)"\x27,"}' | sort | uniq >> unique_userid_notfound.txt