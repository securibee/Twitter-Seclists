#!/bin/bash
README=README.md
rm $README 

echo "# Twitter SecLists" >> $README
echo "Last updated on $(date +'%Y/%m/%d')" >> $README
echo -e "\n" >> $README

for d in lists-temp/*; do
  echo "## $(echo $d | awk -F'-' '{ print $1 }')" >> $README 
  echo "$(cat $d/table | sed 's/\"//g')" >> $README
done

echo -e "\n" >> $README

echo "Updated readme"
