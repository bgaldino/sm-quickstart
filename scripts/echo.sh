#/bin/sh
# ----------------------------------
# Colors
# ----------------------------------
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'

function echo_attention() {
  local green='\033[0;32m'
  local no_color='\033[0m'
  echo "${green}$1${no_color}"
}

function echo_red() {
  local red='\033[0;34m'
  local no_color='\033[0m'
  echo "${red}$1${no_color}"
}

function echo_color() {
  case $1 in
  red)
    echo "${RED}$2${NOCOLOR}"
    ;;
  green)
    echo "${GREEN}$2${NOCOLOR}"
    ;;
  orange)
    echo "${ORANGE}$2${NOCOLOR}"
    ;;
  blue)
    echo "${BLUE}$2${NOCOLOR}"
    ;;
  purple)
    echo "${PURPLE}$2${NOCOLOR}"
    ;;
  cyan)
    echo "${CYAN}$2${NOCOLOR}"
    ;;
  gray)
    echo "${LIGHTGRAY}$2${NOCOLOR}"
    ;;
  lightred)
    echo "${LIGHTRED}$2${NOCOLOR}"
    ;;
  lightgreen)
    echo "${LIGHTGREEN}$2${NOCOLOR}"
    ;;
  lightblue)
    echo "${LIGHTBLUE}$2${NOCOLOR}"
    ;;
  lightpurple)
    echo "${LIGHTPURPLE}$2${NOCOLOR}"
    ;;
  yellow)
    echo "${YELLOW}$2${NOCOLOR}"
    ;;
  *)
    echo "${NOCOLOR}$2"
    ;;
  esac
}

function echo_keypair() {
  echo "${CYAN}$1${NOCOLOR}:${ORANGE}$2${NOCOLOR}"
}

function error_and_exit() {
  echo "$1"
  exit 1
}