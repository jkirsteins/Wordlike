set -e 

function urlencode() {
	python3 -c "import urllib.parse, sys; print(urllib.parse.quote(
	sys.argv[1]))" "$1"
}

echo "" > validated.txt

cat *processed.txt | while read word
do
	enc="$(urlencode "$word")"
	echo "==> Testing $word"
	echo "    $enc"
	EXISTS="$(curl -s "https://tezaurs.lv/$enc" | grep Avoti || true)"
	if [ -z "$EXISTS" ]; then
		echo "    $word not found"
	else
		echo "    $word exists"
		echo "$word" >> validated.txt
	fi
done
