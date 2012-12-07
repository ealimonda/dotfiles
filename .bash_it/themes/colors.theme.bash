#!/usr/bin/env bash

__ansiprefix="\[\e["
__ansisuffix="m\]"
__echoprefix="\033["
__echosuffix="m"

__reset="0;"
__resetx="0;"
__bold=";1"
__fgbright="9"
__normal="3"

__black=0
__red=1
__green=2
__yellow=3
__blue=4
__magenta=5
__cyan=6
__white=7

black="${__ansiprefix}${__reset}${__normal}${__black}${__ansisuffix}"
red="${__ansiprefix}${__reset}${__normal}${__red}${__ansisuffix}"
green="${__ansiprefix}${__reset}${__normal}${__green}${__ansisuffix}"
yellow="${__ansiprefix}${__reset}${__normal}${__yellow}${__ansisuffix}"
blue="${__ansiprefix}${__reset}${__normal}${__blue}${__ansisuffix}"
purple="${__ansiprefix}${__reset}${__normal}${__magenta}${__ansisuffix}"
cyan="${__ansiprefix}${__reset}${__normal}${__cyan}${__ansisuffix}"
white="${__ansiprefix}${__reset}${__normal}${__white}${__bold}${__ansisuffix}"
orange="${__ansiprefix}${__reset}${__fgbright}${__red}${__ansisuffix}"

bold_black="${__ansiprefix}${__normal}${__black}${__bold}${__ansisuffix}"
bold_red="${__ansiprefix}${__normal}${__red}${__bold}${__ansisuffix}"
bold_green="${__ansiprefix}${__normal}${__green}${__bold}${__ansisuffix}"
bold_yellow="${__ansiprefix}${__normal}${__yellow}${__bold}${__ansisuffix}"
bold_blue="${__ansiprefix}${__normal}${__blue}${__bold}${__ansisuffix}"
bold_purple="${__ansiprefix}${__normal}${__magenta}${__bold}${__ansisuffix}"
bold_cyan="${__ansiprefix}${__normal}${__cyan}${__bold}${__ansisuffix}"
bold_white="${__ansiprefix}${__normal}${__white}${__bold}${__ansisuffix}"
bold_orange="${__ansiprefix}${__fgbright}${__red}${__bold}${__ansisuffix}"

normal="${__ansiprefix}${__resetx}${__ansisuffix}"
reset_color="${__ansiprefix}39${__ansisuffix}"

# These colors are meant to be used with `echo -e`
echo_black="${__echoprefix}${__reset}${__normal}${__black}${__echosuffix}"
echo_red="${__echoprefix}${__reset}${__normal}${__red}${__echosuffix}"
echo_green="${__echoprefix}${__reset}${__normal}${__green}${__echosuffix}"
echo_yellow="${__echoprefix}${__reset}${__normal}${__yellow}${__echosuffix}"
echo_blue="${__echoprefix}${__reset}${__normal}${__blue}${__echosuffix}"
echo_purple="${__echoprefix}${__reset}${__normal}${__magenta}${__echosuffix}"
echo_cyan="${__echoprefix}${__reset}${__normal}${__cyan}${__echosuffix}"
echo_white="${__echoprefix}${__reset}${__normal}${__white}${__bold}${__echosuffix}"
echo_orange="${__echoprefix}${__reset}${__fgbright}${__red}${__echosuffix}"

echo_bold_black="${__echoprefix}${__normal}${__black}${__bold}${__echosuffix}"
echo_bold_red="${__echoprefix}${__normal}${__red}${__bold}${__echosuffix}"
echo_bold_green="${__echoprefix}${__normal}${__green}${__bold}${__echosuffix}"
echo_bold_yellow="${__echoprefix}${__normal}${__yellow}${__bold}${__echosuffix}"
echo_bold_blue="${__echoprefix}${__normal}${__blue}${__bold}${__echosuffix}"
echo_bold_purple="${__echoprefix}${__normal}${__magenta}${__bold}${__echosuffix}"
echo_bold_cyan="${__echoprefix}${__normal}${__cyan}${__bold}${__echosuffix}"
echo_bold_white="${__echoprefix}${__normal}${__white}${__bold}${__echosuffix}"
echo_bold_orange="${__echoprefix}${__fgbright}${__red}${__bold}${__echosuffix}"

echo_normal="${__echoprefix}${__resetx}${__echosuffix}"
echo_reset_color="${__echoprefix}39${__echosuffix}"

unset __reset
unset __resetx
unset __bold
unset __fgbright
unset __normal

unset __black
unset __red
unset __green
unset __yellow
unset __blue
unset __magenta
unset __cyan
unset __white

unset __ansiprefix
unset __echoprefix
unset __ansisuffix
unset __echosuffix
