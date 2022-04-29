#!/bin/sh

# 4

# Use hunspell to unmunch dict first and filter to 5 length

# -s
# -š
# -a
# -am
# -e
# -i
# 

#cat lv_wordlist_5.txt | grep -r '.*s$' | grep -v -r '.*ās$' | grep -v -r '.*āt' |  grep -v -r '.*os' | grep -v -r '.*as' | grep -v -r '.*ļa' | grep -v -r '.*ēs$' | \
#	grep -v -r '.*īs$' | grep -v -r '.*us$' | grep -v -r '.*es$' | grep -v -r '.*ūs$' | \
#	egrep '^[[:lower:]]+$' | \
#	sort -u > lv_wordlist_s.txt

#cat lv_wordlist_5.txt | grep -r '.*a$' | \
#	grep -v -r '.*īs$' | \
#	egrep '^[[:lower:]]+$' | \
#	sort -u > lv_wordlist_a.txt

cat lv_wordlist_5.txt | grep -r '.*[asše]$' | \
	grep -v -r '.*ās$' | grep -v -r '.*āt$' | grep -v -r '.*os$' | grep -v -r '.*as$' | \
	grep -v -r '.*īs$' | grep -v -r '.*us$' | grep -v -r '.*es$' | grep -v -r '.*ūs$' | \
	grep -v -r '.*ļa$' | grep -v -r '.*ēs$' | \
	grep -v -r '.*aš$' | \
	grep -v -r '.*era$' | \
	grep -v -r '.*eta$' | \
	grep -v -r '.*īla$' | \
	grep -v -r '.*ķa$' | \
	grep -v -r '.*ata$' | \
	grep -v -r '.*īda$' | \
	grep -v -r '.*īta$' | \
	grep -v -r '.*els$' | \
	grep -v -r '.*oja$' | \
	grep -v -r '.*īga$' | \
	grep -v -r '.*rie$' | \
	grep -v -r '.*āta$' | \
	grep -v -r '.*ora$' | \
	grep -v -r '.*ača$' | \
	grep -v -r '.*lie$' | \
	grep -v -r '.*oka$' | \
	grep -v -r '.*oda$' | \
	grep -v -r '.*īsa$' | \
	grep -v -r '.*īna$' | \
	grep -v -r '.*āla$' | \
	grep -v -r '.*ada$' | \
	grep -v -r '.*ēda$' | \
	grep -v -r '.*ota$' | \
	grep -v -r '.*īņa$' | \
	grep -v -r '.*pūš$' | \
	grep -v -r '.*āks$' | \
	grep -v -r '.*rga$' | \
	grep -v -r '.*oba$' | \
	grep -v -r '.*ica$' | \
	grep -v -r '.*āba$' | \
	grep -v 'velba' | \
	grep -v 'valba' | \
	grep -v 'žilba' | \
	grep -v 'šķība' | \
	grep -v 'gārgs' | \
	grep -v 'sirgs' | \
	grep -v 'žirgs' | \
	grep -v 'žigla' | \
	grep -v 'sigla' | \
	grep -v 'šķūņa' | \
	grep -v 'ņirgs' | \
	grep -v 'vraka' | \
	egrep '^[[:lower:]]+$' \
	> lv_A.tmp.txt

# Reinstate false positive eliminations
echo 'gleta' >> lv_A.tmp.txt
echo 'pieta' >> lv_A.tmp.txt
echo 'stera' >> lv_A.tmp.txt
echo 'vieta' >> lv_A.tmp.txt
echo 'lieta' >> lv_A.tmp.txt
echo 'opera' >> lv_A.tmp.txt
echo 'gnīda' >> lv_A.tmp.txt
echo 'grīda' >> lv_A.tmp.txt
echo 'švīta' >> lv_A.tmp.txt
echo 'svīta' >> lv_A.tmp.txt
echo 'flora' >> lv_A.tmp.txt
echo 'spora' >> lv_A.tmp.txt
echo 'sloka' >> lv_A.tmp.txt
echo 'kroka' >> lv_A.tmp.txt
echo 'akota' >> lv_A.tmp.txt
echo 'grota' >> lv_A.tmp.txt
echo 'kvota' >> lv_A.tmp.txt
echo 'slota' >> lv_A.tmp.txt
echo 'bļoda' >> lv_A.tmp.txt
echo 'grēda' >> lv_A.tmp.txt
echo 'grīņa' >> lv_A.tmp.txt
echo 'zvīņa' >> lv_A.tmp.txt
echo 'morga' >> lv_A.tmp.txt
echo 'murga' >> lv_A.tmp.txt
echo 'sērga' >> lv_A.tmp.txt
echo 'ņerga' >> lv_A.tmp.txt
echo 'ņirga' >> lv_A.tmp.txt
echo 'žurga' >> lv_A.tmp.txt

cat lv_A.tmp.txt | sort -u > lv_A.txt
rm lv_A.tmp.txt



