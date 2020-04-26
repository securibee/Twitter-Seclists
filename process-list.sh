#!/bin/bash
DIR=$1
FILES="$DIR/raw/*"

rm $DIR/table

echo "| handle | name |" >> $DIR/table
echo "|--------|------|" >> $DIR/table

for f in $FILES
do
  cat $f | jq '[.[] ] | .[0][] | "|[@"+.screen_name+"](https://twitter.com/"+.screen_name+") | "+.name+"|"' >> $DIR/table-tmp
done

echo "$(cat $DIR/table-tmp | sed 's/\"//g' | sort)" >> $DIR/table

echo "Done processing $DIR"
