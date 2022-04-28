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
	grep -v -r '.*ķa$' | \
	egrep '^[[:lower:]]+$' \
	> lv_A.tmp.txt

# Reinstate false positive eliminations
echo 'gleta' >> lv_A.tmp.txt
echo 'pieta' >> lv_A.tmp.txt
echo 'stera' >> lv_A.tmp.txt
echo 'vieta' >> lv_A.tmp.txt
echo 'lieta' >> lv_A.tmp.txt
echo 'opera' >> lv_A.tmp.txt

cat lv_A.tmp.txt | sort -u > lv_A.txt
rm lv_A.tmp.txt



