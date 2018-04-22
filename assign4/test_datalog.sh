#!/usr/bin/env bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NORMAL=$(tput sgr0)

saturation_test () {
  printf "+ Running saturation-only test ${1}... "
  DIFF=$(diff --ignore-space-change <(cat ${1}.exp | sort) <(./datalog.native test-saturation ${1} | sort))

  if [[ $? == 0 ]]
  then
     printf "${GREEN}passed...${NORMAL}\n"
  else
     printf "${RED}failed...${NORMAL}\n"
     printf "\nDiff of Expected and Actual Output:\n${DIFF}\n\n"
     printf "Program:\n$(./datalog.native print-program ${1})\n\n"
  fi
}

program_query_test () {
  printf "+ Running program query test ${1}... "
  DIFF=$(diff --ignore-space-change <(cat ${file}.exp | sort) <(./datalog.native test ${1} ${1}.query | sort))

  if [[ $? == 0 ]]
  then
     printf "${GREEN}passed...${NORMAL}\n"
  else
     printf "${RED}failed...${NORMAL}\n"
     printf "\nDiff of Expected and Actual Output:\n${DIFF}\n\n"
     printf "Program:\n$(./datalog.native print-program ${1})\n\n"
     printf "Query:\n$(./datalog.native print-query ${1}.query)\n\n"
  fi
}

if [ "$1" != "" ]; then
    file=$1
    if [ ! -f ${file}.query ]; then
      saturation_test $1
    else
      program_query_test $1
    fi
    exit
fi

printf "=== Saturation Unit Tests ===\n"
for file in $(find ./tests/saturation -maxdepth 1 -type f -name "*.program"); do
  saturation_test $file
done

printf "=== Datalog Tests ===\n"
for file in $(find ./tests -maxdepth 1 -type f -name "*.program"); do
  program_query_test $file
done
