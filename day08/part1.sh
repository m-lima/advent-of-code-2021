#!/bin/bash

count=0

while read -r line
do
  output=(`cut -d'|' -f2 <<< ${line}`)
  for out in ${output[@]}
  do
    if (( ${#out} <= 4 || ${#out} == 7 ))
    then
      count=$((count + 1))
    fi
  done
done < input.txt

echo $count
