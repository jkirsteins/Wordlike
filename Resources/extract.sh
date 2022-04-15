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
	egrep '^[[:lower:]]+$' | \
	sort -u 


