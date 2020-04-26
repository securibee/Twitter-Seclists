#!/bin/bash

rm README.md

for d in lists/*; do
  echo $(cat $d/table) >> README.md
done

echo "Updated readme"
