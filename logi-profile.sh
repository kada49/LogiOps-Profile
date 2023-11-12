#!/bin/bash
MY_PATH="$(dirname -- "${BASH_SOURCE[0]}")"

array=()

function getProfiles() {
  search_dir=$MY_PATH/profiles
  for entry in "$search_dir"/*; do
  
    IFS='/' read -ra ADDR <<< "$entry"
    for i in "${ADDR[@]}"; do
      if [[ "$i" == *".cfg" ]]; then
        IFS='.' read -ra name <<< "$i"
        for n in "${name[@]}"; do
          if [ "$n" != "cfg" ]; then
            array+=( "$n" )
          fi
        done
      fi
    done
  done
}

  getProfiles

  if [ "$1" == "--list" ] || [ "$1" == "-l" ]; then
    echo "Available profiles:"
    for item in "${array[@]}"; do
      echo "  ${item}"
    done
  else
    contains="0"
    for i in "${array[@]}"; do
      if [ "$i" == "$1" ]; then
        contains="1"
      fi
    done

    if [ "$contains" == "0" ]; then
      echo "There exists no profile called '${1}'"
    else
      echo "Setting profile..."
      if [ -f /etc/logid.cfg ]; then
        sudo rm /etc/logid.cfg
      fi
      sudo cp ${MY_PATH}/profiles/${1}.cfg /etc/logid.cfg
      sudo systemctl restart logid
    fi
  fi