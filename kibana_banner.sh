#!/bin/sh

ProgName=$(basename $0)

core_append(){
  cat << EOF
/* BEGIN EXPR BANNER */
body::after {
  content: "$2";
  position: fixed;
  top: 0;
  padding: 2px;
  z-index: 99999999;
  width: 100%;
  background-color: $1;
  text-align: center;
  font-weight: bold;
}
#kibana-body::after {
  content: $2;
  position: fixed;
  bottom: 0;
  padding: 2px;
  z-index: 99999999;
  width: 100%;
  background-color: $1;
  text-align: center;
  font-weight: bold;
}
.header-global-wrapper {
  width: 100%;
  position: fixed;
  top: 15px;
  z-index: 10; }
.header-global-wrapper + .app-wrapper:not(.hidden-chrome) {
  top: 48px;
  left: 48px; }
  .header-global-wrapper + .app-wrapper:not(.hidden-chrome) .euiFlyout {
    top: 48px;
    height: calc(100% - 48px); }
@media only screen and (max-width: 574px) {
  .header-global-wrapper + .app-wrapper:not(.hidden-chrome) {
    left: 0; } }
@media only screen and (min-width: 575px) and (max-width: 767px) {
  .header-global-wrapper + .app-wrapper:not(.hidden-chrome) {
    left: 0; } }
/* END EXPR BANNER */
EOF
}

command_help(){
  echo "Usage: $ProgName <subcommand> [options]"
  echo "Subcommands:"
  echo "  set - Add or update the properties of the Kibana banner"
  echo "  remove - Remove the Kibana banner"
  echo ""
  echo "For help with each subcommand run:"
  echo "$ProgName <subcommand> -h|--help"
  echo ""
  echo "Example Usage:"
  echo "  > $ProgName set /opt/path/to/kibana-7.8.0-darwin-x86_64 red 'This page contains dynamic content -- Highest Possible Content is SECRET//NOFORN'"
  echo "  > $ProgName remove \$KIB_HOME"
  echo ""
} 

command_set(){
  case $1 in
    "" | "-h" | "--help")
      echo "$ProgName set <kibana_dir> <color> <message>"
      echo "  <kibana_dir> - Path Kibana. Usually \$KIB_HOME."
      echo "  <color> - a valid CSS3 color, such as 'red' or '#ababab'"
      echo "  <message> - The message to display in the banner. Can be any string, such as 'UNCLASS'"
      ;;
    *)
      echo "$(core_append $2 $3)" >> "$1/built_assets/css/core.dark.css"
      echo "$(core_append $2 $3)" >> "$1/built_assets/css/core.light.css"
      ;;
  esac
}

command_remove(){
  case $1 in
    "" | "-h" | "--help")
      echo "$ProgName remove <kibana_dir>"
      echo "  <kibana_dir> - Path Kibana. Usually \$KIB_HOME."
      ;;
    *)
      sed '/\/\* BEGIN EXPR BANNER \*\//,/\/\* END EXPR BANNER \*\/d' $1
  esac
}

subcommand=$1
case $subcommand in
  "" | "-h" | "--help")
    command_help
    ;;
  *)
  shift
  command_${subcommand} $@
  if [ $? = 127 ]; then
    echo "Error: '$subcommand' is not a known subcommand." >&2
    echo "  Run '$ProgName --help' for a list of known subcommands." >&2
  fi
  ;;
esac
