cite about-plugin
about-plugin 'display info about your battery charge level'

battery_percentage(){
  about 'displays battery charge as a percentage of full (100%)'
  group 'battery'

  if command_exists acpi;
  then
    local ACPI_OUTPUT=$(acpi -b)
    case $ACPI_OUTPUT in
      *" Unknown"*)
        local PERC_OUTPUT=$(echo $ACPI_OUTPUT | head -c 22 | tail -c 2)
        case $PERC_OUTPUT in
          *%)
            echo "0${PERC_OUTPUT}" | head -c 2
            ;;
          *)
            echo ${PERC_OUTPUT}
            ;;
        esac
        ;;
      *" Discharging"*)
        local PERC_OUTPUT=$(echo $ACPI_OUTPUT | head -c 26 | tail -c 2)
        case $PERC_OUTPUT in
          *%)
            echo "0${PERC_OUTPUT}" | head -c 2
            ;;
          *)
            echo ${PERC_OUTPUT}
            ;;
        esac
        ;;
      *" Charging"*)
        local PERC_OUTPUT=$(echo $ACPI_OUTPUT | head -c 23 | tail -c 2)
        case $PERC_OUTPUT in
          *%)
            echo "0${PERC_OUTPUT}" | head -c 2
            ;;
          *)
            echo ${PERC_OUTPUT}
            ;;
        esac
        ;;
      *" Full"*)
        echo '99'
        ;;
      *)
        echo '-1'
        ;;
    esac
  elif command_exists ioreg;
  then
    # http://hints.macworld.com/article.php?story=20100130123935998
    #local IOREG_OUTPUT_10_6=$(ioreg -l | grep -i capacity | tr '\n' ' | ' | awk '{printf("%.2f%%", $10/$5 * 100)}')
    #local IOREG_OUTPUT_10_5=$(ioreg -l | grep -i capacity | grep -v Legacy| tr '\n' ' | ' | awk '{printf("%.2f%%", $14/$7 * 100)}')
    local IOREG_OUTPUT="$(ioreg -n AppleSmartBattery -r)"
    local IOREG_PARSED=$(echo "$IOREG_OUTPUT" | awk '$1~/Capacity/{c[$1]=$3} END{OFMT="%.2f%%"; max=c["\"MaxCapacity\""]; print (max>0? 100*c["\"CurrentCapacity\""]/max: "?")}')
    local OUT=""
    if [ "$1" == "chargestatus" ]; then
	    if echo "$IOREG_OUTPUT" | grep '"ExternalConnected" = No' >/dev/null; then
		    OUT="N|"
	    else
		    OUT="Y|"
	    fi
    fi
    case $IOREG_PARSED in
      100*)
        echo "${OUT}99"
        ;;
      *)
        echo "${OUT}${IOREG_PARSED:0:2}"
        ;;
    esac
  else
    echo "no"
  fi
}

battery_charge(){
  about 'graphical display of your battery charge'
  group 'battery'
  local DEPLETED_COLOR="${normal}"
  local FULL_COLOR="${green}"
  local HALF_COLOR="${yellow}"
  local DANGER_COLOR="${red}"
  local BATTERY_STATUS=$(battery_percentage chargestatus)
  local BATTERY_PERC=${BATTERY_STATUS#*|}
  # Full char
  local F_C=""
  # Depleted char
  local D_C=""
  # A/C char
  local AC_C=""
  if [ "$BASH_IT_SAFE_CHARSET" == "true" ]; then
    if [ "${BATTERY_STATUS%|*}" == "N" ]; then
      F_C="+"
      D_C="-"
    else
      F_C='#'
      D_C='>'
    fi
    AC_C="z"
  else
    if [ "${BATTERY_STATUS%|*}" == "N" ]; then
      F_C='■'
      D_C='□'
    else
      F_C='▸'
      D_C='▹'
    fi
    AC_C='⚡'
  fi

  case $BATTERY_PERC in
    no)
      echo "${FULL_COLOR}${AC_C}${normal}"
      #echo ""
      ;;
    9*)
      echo "${FULL_COLOR}${F_C}${F_C}${F_C}${F_C}${F_C}${normal}"
      ;;
    8*)
      echo "${FULL_COLOR}${F_C}${F_C}${F_C}${F_C}${HALF_COLOR}${F_C}${normal}"
      ;;
    7*)
      echo "${FULL_COLOR}${F_C}${F_C}${F_C}${F_C}${DEPLETED_COLOR}${D_C}${normal}"
      ;;
    6*)
      echo "${FULL_COLOR}${F_C}${F_C}${F_C}${HALF_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${normal}"
      ;;
    5*)
      echo "${FULL_COLOR}${F_C}${F_C}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${normal}"
      ;;
    4*)
      echo "${FULL_COLOR}${F_C}${F_C}${HALF_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${normal}"
      ;;
    3*)
      echo "${FULL_COLOR}${F_C}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${D_C}${normal}"
      ;;
    2*)
      echo "${FULL_COLOR}${F_C}${HALF_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${D_C}${normal}"
      ;;
    1*)
      echo "${FULL_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${D_C}${D_C}${normal}"
      ;;
    05)
      echo "${DANGER_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${D_C}${D_C}${normal}"
      ;;
    04)
      echo "${DANGER_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${D_C}${D_C}${normal}"
      ;;
    03)
      echo "${DANGER_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${D_C}${D_C}${normal}"
      ;;
    02)
      echo "${DANGER_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${D_C}${D_C}${normal}"
      ;;
    0*)
      echo "${HALF_COLOR}${F_C}${DEPLETED_COLOR}${D_C}${D_C}${D_C}${D_C}${normal}"
      ;;
    *)
      echo "${FULL_COLOR}${AC_C}${normal}"
      #echo "${DANGER_COLOR}UNPLG${normal}"
      ;;
  esac
}
