#!/bin/bash

UPPER_LIMIT=$1
let SPLIT=UPPER_LIMIT/2

Primes=("$(seq $UPPER_LIMIT)")

i=1
until(((i+=1)>SPLIT))
do
  if [[ -n $Primes[i] ]]
  then
    t=$i
    until(((t+=i)>UPPER_LIMIT))
    do
      Primes[t]=
    done
  fi
done
echo ${Primes[*]}

exit 0
