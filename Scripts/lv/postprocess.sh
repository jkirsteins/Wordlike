set -e

rm *processed.txt


function postprocess {
  IN="$1"
  OUT="$1-processed.txt"

  cat "$IN" | \
	grep -v 'Reziduālis' | \
	grep -v 'Īpašvārds' | \
	grep -v 'Prievārds' | \
	grep -v 'Apstākļa_vārds' | \
	grep -v 'Izsauksmes_vārds' | \
	grep -v 'Sugas_vārds' | \
	grep -v 'Partikula' | \
	grep -v 'Sākas_ar_lielo_burtu' | \
	grep -v 'acoot' | \
	grep -v 'aciņs' | \
	grep -v 'aģīts' | \
	grep -v 'aģīša' | \
	grep -v 'abēja' | \
	grep -v 'adīšs' | \
	grep -v 'afērs' | \
	grep -v 'abējs' | \
	grep -v 'acīts' | \
	awk '{print $3}' | \
	grep '^.....$' | \
	grep -v '[^[:lower:]]' | \
	sort -u > "$OUT"
}

for filename in out.lvfull*; do
	echo "==> $filename"
	postprocess "$filename"
done
