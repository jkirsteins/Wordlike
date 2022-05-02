#!/bin/sh

echo "" > fr_lemmas_5_v2.tmp.txt

cat fr_lemmas_5.txt | sort -u > fr_lemmas_t_sorted.txt

cat fr_lemmas_sorted.txt | grep -v '[^[:lower:]]' | \
		tr 'ç' c | \
		tr 'é' e | \
		tr 'â' a | \
		tr 'ê' e | \
		tr 'î' i | \
		tr 'ô' o | \
		tr 'û' u | \
		tr 'à' a | \
		tr 'è' e | \
		tr 'ì' i | \
		tr 'ò' o | \
		tr 'ù' u | \
		tr 'ë' e | \
		tr 'ï' i | \
		tr 'ü' u | \
		tr 'œ' oe | \
		tr 'æ' ae | \
		grep -v "ᵉ" | \
		grep -v "xx" | \
		grep -v "iii" | \
		grep -v "xv" | \
		grep -v "xl" | \
	       grep -x '.....' | \
	egrep '.*(ez|la|er|ir|me|ne|oc|ni|et|te|le|re|ri|en|li|oi|ix|if|ue|uf|ie|al|as|ve|ac|ah|pa|ze|me|pe|ge|in|he|ux|on|ot|rs|fe|de|ar|be|ci|fi|nt|io|an|um|us|is|si|ss|mb|uc|ds|ng|ka|bi|eu|ur|ui|sa|ta|ou|id|or|it|at|el|ce)$' | \
	grep -v ziber | \
	grep -v weber | \
	grep -v aaron | \
	grep -v baise | \
	sort -u > fr_lemmas_5_v2.txt

# Process the allowed guesses a bit less
cat fr_full.txt | grep -v '[^[:alnum:]]' | \
		tr 'ç' c | \
		tr 'é' e | \
		tr 'â' a | \
		tr 'ê' e | \
		tr 'î' i | \
		tr 'ô' o | \
		tr 'û' u | \
		tr 'à' a | \
		tr 'è' e | \
		tr 'ì' i | \
		tr 'ò' o | \
		tr 'ù' u | \
		tr 'ë' e | \
		tr 'ï' i | \
		tr 'ü' u | \
		tr 'œ' oe | \
		tr 'æ' ae | \
		grep -v "ᵉ" | \
		grep -v "xx" | \
		grep -v "iii" | \
		grep -v "xv" | \
		grep -v "xl" | \
		grep -x '.....' | awk '{print tolower($0)}' > fr_guesses.txt
