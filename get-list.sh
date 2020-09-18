#!/bin/bash
[[ -z $1 ]] && LIST_ID="1253517962272743424" || LIST_ID=$1
CURSOR="-1"
LIST_NAME=$(curl -s -H "Authorization: Bearer $TWITTER_TOKEN" "https://api.twitter.com/1.1/lists/show.json?list_id=$LIST_ID" | jq -r '.slug')
DIR=$PWD/lists/$LIST_NAME-$LIST_ID
RAW="$DIR/json"

mkdir -p $RAW
rm -rf "$RAW"/*

get () {
  while [[ $CURSOR -ne 0 ]]; do
    curl -s -H "Authorization: Bearer $TWITTER_TOKEN" \
    "https://api.twitter.com/1.1/lists/members.json?list_id=$LIST_ID&cursor=$CURSOR&skip_status=true" \
    >> $RAW/$CURSOR;
    CURSOR=$(cat $RAW/$CURSOR | jq '.next_cursor');
  done
}

process () {
  sub_markdown="$DIR"/members.md
  sub_usernames="$DIR"/member-usernames.txt
  sub_usernames_old="$DIR"/member-usernames-old.txt

  [[ -f "$sub_usernames" ]] && cp "$sub_usernames" "$sub_usernames_old" 
  rm -rf "$sub_markdown" "$sub_usernames"

  echo "| handle | name | description |" >> "$sub_markdown"
  echo "|--------|------|-------------|" >> "$sub_markdown"

  cat "$RAW"/* | jq -r '[.[] ] | .[0][] | "|[@"+.screen_name+"](https://twitter.com/"+.screen_name+") | "+.name+" | "+.description+"" | gsub("[\\n\\t]"; "")' | sort -u >> "$sub_markdown"
  cat "$RAW"/* | jq -r '[.[] ] | .[0][] | .screen_name' | sort -u >> "$sub_usernames"

  comm "$sub_usernames_old" "$sub_usernames" -13 > "$DIR"/additions.txt 
  cat "$DIR"/additions.txt
}

readme () {
  README=README.md
  rm "$README"

  echo "# Twitter SecLists" >> "$README"
  cat <<EOT >> "$README"
Once I found out about Twitter lists I immediately fell in love. Shortly after I started curating my own and currently it's the only way I consume Twitter. On desktop, I use Tweetdeck and on mobile I have my lists pinned for easy swiping.

I'll keep this repo up-to-date with new additions! Currently only the bug bounty list is listed here.

<a href="https://www.buymeacoffee.com/securibee" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/yellow_img.png" alt="Buy Me A Coffee" ></a>
EOT
  echo -e "\n" >> "$README"
  echo "Last updated on $(date +'%Y/%m/%d')" >> "$README"
  echo -e "\n" >> "$README"

  for d in lists/*; do
    echo "## $(echo "$d" | awk -F'/' '{ print $2 }' | awk -F'-' '{ print $1}') list" >> "$README"
    echo "https://twitter.com/i/lists/$(echo $d | awk -F'/' '{ print $2 }' | awk -F'-' '{ print $2}')" >> "$README"
    echo "### Latest additions" >> "$README"
    echo $(cat "$DIR"/additions.txt) >> "$README"
    echo -e "\n" >> "$README"
    echo "### Members" >> "$README"
    echo "$(cat "$d"/members.md | sed 's/\"//g')" >> "$README"
  done
}

cleanup () {
  rm -rf "$RAW"
}

get
process
readme
cleanup
