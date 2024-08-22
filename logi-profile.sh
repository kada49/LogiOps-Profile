#!/bin/bash
MY_PATH="$(dirname -- "${BASH_SOURCE[0]}")"

array=()
profile=${2:-"NONE"}

function main() {
  getProfiles
  
  case "$1" in
    "list") listProfiles ;;
    "selected") echo "Selected profile: $(cat ./.selected)" ;;
    "edit")
      local editor=${FCEDIT:-${VISUAL:-${EDITOR:-vi}}}
      profileIsAvaliable
      if [ "$?" -eq 0 ]; then
        echo "Profile $profile does not exist! Execute '$0 list' to find all available profiles"
        return
      fi
      $editor $MY_PATH/profiles/$profile.cfg
      ;;
    "create")
      local editor=${FCEDIT:-${VISUAL:-${EDITOR:-vi}}}
      profileIsAvaliable
      if [ "$?" -eq 1 ]; then
        echo "Profile $profile already exists! Please choose a different name"
        return
      fi
      $editor $MY_PATH/profiles/$profile.cfg
      if [ -f $MY_PATH/profiles/$profile.cfg ]; then
        echo "Successfully created profile: $profile"
      else
        echo "Aborted creating a new profile"
      fi
      ;;
    "set")
      profileIsAvaliable
      if [ "$?" -eq 1 ]; then
        checkIfSu
        echo "Setting profile..."
        if [ -f /etc/logid.cfg ]; then
          rm /etc/logid.cfg
        fi
        cp $MY_PATH/profiles/$profile.cfg /etc/logid.cfg
        systemctl restart logid
        echo "$profile" > $MY_PATH/.selected
      else
        echo "The profile $profile does not exist! Execute '$0 list' to find all available profiles"
      fi
      ;;
    *) printUsage ;;
  esac

}

function printUsage() {
  echo TODO
}

function profileIsAvaliable() {
  contains=0
  for i in "${array[@]}"; do
    if [ "$i" == "$profile" ]; then
      return 1
    fi
  done
  return 0
}

function checkIfSu() {
  if [ "$EUID" -ne 0 ]; then
    echo "Please run as root!"
    exit 1
  fi
}

function listProfiles() {
  echo "Available profiles:"
  for item in "${array[@]}"; do
    echo "  $item"
  done
}

function getProfiles() {
  local search_dir=$MY_PATH/profiles
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
