#!/bin/bash
LIST_ID=$1
LIST_NAME=$(curl -s https://twitter.com/i/lists/$LIST_ID | grep "<title>" | awk -F'/' '{ print $2 }' | awk '{print $1}')
CURSOR="-1"
DIR=$PWD/lists-temp/$LIST_NAME-$LIST_ID
RAW="$DIR/raw"

rm -rf $DIR
mkdir -p $RAW

cp $PWD/lists/$LIST_NAME.txt $DIR/$LIST_NAME-old
git pull
cat $DIR/$LIST_NAME-old | anew $PWD/lists/$LIST_NAME.txt > $DIR/additions

if [ -s $(cat "$DIR"/additions | wc -l) ]; then
  NAMES=$(cat $DIR/additions | xargs | sed -e 's/ /,/g')
  echo $NAMES
#  #curl -s -X POST -h \ "Authorization: Bearer $(cat $PWD/.env | head -n 1)" \
#  #"https://api.twitter.com/1.1/lists/members/create_all.json?screen_name=$NAMES&list_id=$LIST_ID"
fi;

while true; do
  if [ $CURSOR -eq 0 ]; then
    break
  fi;
  curl -s -X GET -H "Authorization: Bearer $(cat $PWD/.env | head -n 1)" \
  "https://api.twitter.com/1.1/lists/members.json?list_id=$LIST_ID&cursor=$CURSOR&skip_status=true" \
  >> $RAW/$CURSOR
  CURSOR=$(cat $RAW/$CURSOR | jq '.next_cursor')
done

./process-list.sh $DIR
