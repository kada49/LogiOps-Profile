#!/bin/bash
MY_PATH="$(dirname -- "${BASH_SOURCE[0]}")"

array=()
PARAM1=${1:-"NONE"}

function main() {
  getProfiles

  if [ "$PARAM1" == "--list" ] || [ "$PARAM1" == "-l" ]; then
    echo "Available profiles:"
    for item in "${array[@]}"; do
      echo "  ${item}"
    done

    return
  fi


  if [ "$PARAM1" == "--selected" ] || [ "$PARAM1" == "-s" ]; then
    echo "Selected profile: $(cat ./selected)"

    return
  fi


  contains="0"
  for i in "${array[@]}"; do
    if [ "$i" == "$PARAM1" ]; then
      contains="1"
    fi
  done

  if [ "$contains" == "0" ]; then
    echo "There exists no profile called '${PARAM1}'"
  else
    echo "Setting profile..."
    if [ -f /etc/logid.cfg ]; then
      sudo rm /etc/logid.cfg
    fi
    sudo cp ${MY_PATH}/profiles/${PARAM1}.cfg /etc/logid.cfg
    sudo systemctl restart logid
    echo "$PARAM1" > ./selected
  fi
}

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


  
main "$@"
