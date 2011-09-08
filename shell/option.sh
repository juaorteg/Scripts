#!/bin/sh
while getopts ":b:v:cb" OPT;do
  case $OPT in
    b ) echo "yes"
      ;;
    c ) echo "no"
      ;;
    v ) echo "version 1"
      ;;
    * ) echo "nothing"
      ;;
  esac
done

echo $OPTIND
