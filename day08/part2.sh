#!/bin/bash

function sort_digits {
  temp=(`(fold -w 1 <<< ${1}) | sort`)
  echo ${temp[@]}
}

count=0

while read -r line; do
  unset A B C D E F G zero one two three four five six seven eight nine
  jig=(`cut -d'|' -f1 <<< ${line}`)

  while [ -z ${A} ] \
     || [ -z ${B} ] \
     || [ -z ${C} ] \
     || [ -z ${D} ] \
     || [ -z ${E} ] \
     || [ -z ${F} ] \
     || [ -z ${G} ]; do

    for segments in ${jig[@]}; do
      case ${#segments} in
        2) [ -z ${one} ] && one=${segments} ;;
        3)
          [ -z ${seven} ] && seven=${segments}
          [ -z ${A} ] && [ ! -z ${one} ] && A=`sed "s/[${one}]//g" <<< ${seven}`
          ;;
        4) [ -z ${four} ] && four=${segments} ;;
        6)
          if [ -n ${one} ] && [ ${seven} ] && [ -n ${four} ]; then
            iter=(${one} ${seven} ${four})
            temp=${segments}
            for i in ${iter[@]}; do
              temp=`sed "s/[${i}]//g" <<< ${temp}`
            done

            case ${#temp} in
              1) [ -z ${G} ] && G=${temp} ;;
              2)
                if [ -z ${E} ] && [ ! -z ${G} ]; then
                  E=`sed "s/${G}//" <<< ${temp}`
                fi
                if [ -z ${B} ]; then
                  temp=`sed "s/[${seven}${E}${G}]//g" <<< ${segments}`
                  (( ${#temp} == 1 )) && B=${temp}
                fi
                if [ -z ${C} ]; then
                    temp=`sed "s/[${segments}]//g" <<< ${one}`
                    if (( ${#temp} == 1 )); then
                      C=`sed "s/[${segments}]//g" <<< ${one}`
                      F=`sed "s/${C}//" <<< ${one}`
                    fi
                fi
                ;;
            esac
          fi
          ;;
        7)
          [ -z ${eight} ] && eight=${segments}
          [ -z ${B} ] || D=`sed "s/[${seven}${B}${E}${G}]//g" <<< ${segments}`
          ;;
      esac
    done
  done

  zero=`sort_digits "${A}${B}${C}${E}${F}${G}"`
  one=`sort_digits "${C}${F}"`
  two=`sort_digits "${A}${C}${D}${E}${G}"`
  three=`sort_digits "${A}${C}${D}${F}${G}"`
  four=`sort_digits "${B}${C}${D}${F}"`
  five=`sort_digits "${A}${B}${D}${F}${G}"`
  six=`sort_digits "${A}${B}${D}${E}${F}${G}"`
  seven=`sort_digits "${A}${C}${F}"`
  eight=`sort_digits "${A}${B}${C}${D}${E}${F}${G}"`
  nine=`sort_digits "${A}${B}${C}${D}${F}${G}"`

  inner_count=0

  output=(`cut -d'|' -f2 <<< ${line}`)
  for out in ${output[@]}; do
    out=`sort_digits ${out}`
    case "${out}" in
      "${zero}") inner_count=$(( inner_count * 10 )) ;;
      "${one}") inner_count=$(( inner_count * 10 + 1 )) ;;
      "${two}") inner_count=$(( inner_count * 10 + 2 )) ;;
      "${three}") inner_count=$(( inner_count * 10 + 3 )) ;;
      "${four}") inner_count=$(( inner_count * 10 + 4 )) ;;
      "${five}") inner_count=$(( inner_count * 10 + 5 )) ;;
      "${six}") inner_count=$(( inner_count * 10 + 6 )) ;;
      "${seven}") inner_count=$(( inner_count * 10 + 7 )) ;;
      "${eight}") inner_count=$(( inner_count * 10 + 8 )) ;;
      "${nine}") inner_count=$(( inner_count * 10 + 9 )) ;;
    esac
  done
  count=$(( count + inner_count ))
done < input.txt

echo $count
