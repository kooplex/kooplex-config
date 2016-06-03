#!/bin/bash

fdqn2ldap () {
  local aa q fdqn=$@
  IFS=. read -ra aa <<< "$fdqn"
  q=0
  for i in "${aa[@]}"
  do
    if test $q -gt 0
    then
     printf ','
    fi
    printf 'dc=%s' "$i"
	q=$((q + 1))
  done
  printf '\n'
}

fdqn2ldap "$@"