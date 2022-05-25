
function urlencode() {
	python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$1"
}

function testmot() {
    word="$1"
    echo "==> Testing $word"
    result="$(curl --compressed -s "https://1mot.net/$word" | grep "est valide au")"
	if [ -z "$result" ]; then 
            echo "    invalid :("
            return 1
        else   
            echo "    valid"
            return 0
        fi
}

echo "" > fr_G.validated.txt
echo "" > fr_A.validated.txt

echo "==> Processing A"
cat fr_A.txt | while read word
do
	enc="$(urlencode "$word")"
        testmot "$word"
	if [ $? == 0 ]; then 
        echo "$word" >> fr_A.validated.txt
    fi
done

echo "==> Processing G"
cat fr_G.txt | while read word
do
	enc="$(urlencode "$word")"
        testmot "$word"
	if [ $? == 0 ]; then 
        echo "$word" >> fr_G.validated.txt
    fi
done
