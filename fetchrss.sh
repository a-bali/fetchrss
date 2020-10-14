#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <feeds> <history> <output>
  feeds:    a text file, listing the RSS feeds to fetch (one link per line)
  history:  a text file, listing already downloaded files (kept by this program)
  output:   the directory where downloaded files should be saved"
    exit 1
fi

xmlq() {
  echo $data | xmllint --xpath $1 -
}

while read url; do
    data=$(wget -q -O - "$url")
    feed=$(xmlq '//channel/title/text()')
    count=$(xmlq 'count(//item)')

    echo "$count items in $feed"

    for i in $(seq 1 $count); do
	title=$(xmlq '//item['$i']/title/text()')
	link=$(xmlq '//item['$i']/link/text()')

	if ! [ -f "$2" ] || ! grep -q "$link" "$2"; then
	    echo "Downloading $title ($link) from $feed"
            wget -q --content-disposition -P "$3" $link && echo "[$(date)] $title $link" >> "$2"
	fi
    done

done < "$1"
