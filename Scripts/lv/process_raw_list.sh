#!/bin/bash

set -e 

#!/bin/bash
for filename in lvfull*; do
	echo "==> $filename"
	../LVTagger/morphotagger.sh <$filename >"out.$filename"
done

