#!/bin/bash
mkdir -p $PWD/lists

DIR=$1
FILES="$DIR/raw/*"
LIST_NAME=$(echo $DIR | awk -F'temp/' '{print $2}' | awk -F'-' '{print $1}')
LIST_FILE=$PWD/lists/$LIST_NAME.txt

rm $DIR/table

echo "| handle | name |" >> $DIR/table
echo "|--------|------|" >> $DIR/table

for f in $FILES
do
  cat $f | jq '[.[] ] | .[0][] | "|[@"+.screen_name+"](https://twitter.com/"+.screen_name+") | "+.name+"|"' >> $DIR/table-tmp
  cat $f | jq '[.[] ] | .[0][] | .screen_name' >> $DIR/list-tmp
done

echo "$(cat $DIR/table-tmp | sed 's/\"//g' | sort -u)" >> $DIR/table
[ ! -f $LIST_FILE ] && echo "$(cat $DIR/list-tmp | sed 's/\"//g' | sort -u)" > $LIST_FILE

./create-readme.sh
