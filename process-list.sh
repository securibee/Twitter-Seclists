#!/bin/bash
DIR=$1
FILES="$DIR/raw/*"

rm $DIR/table

echo "| handle | name |" >> $DIR/table
echo "|--------|------|" >> $DIR/table

for f in $FILES
do
  cat $f | jq '[.[] ] | .[0][] | "|[@"+.screen_name+"](https://twitter.com/"+.screen_name+") | "+.name+"|"' >> $DIR/table
done

echo "Done processing $DIR"