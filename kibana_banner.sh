#!/bin/sh

ProgName=$(basename $0)

core_append(){
  cat << EOF

/* BEGIN EXPR BANNER */
html::before {
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
html::after {
  content: "$2";
  position: fixed;
  bottom: 0;
  padding: 2px;
  z-index: 99999999;
  width: 100%;
  background-color: $1;
  text-align: center;
  font-weight: bold;
}
.euiHeader.euiHeader--fixed {
  top: 24px;
}
.euiCollapsibleNav {
  top: 73px !important;
  height: calc(100% - 97px) !important;
}
.euiFlyout {
  top: 73px !important;
  height: calc(100% - 97px) !important;
}
.app-wrapper {
  margin-top: 24px !important;
  margin-bottom: 24px !important;
}
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
  echo "  > $ProgName set /opt/path/to/kibana-7.8.0-darwin-x86_64 '#54B399' 'This page contains dynamic content -- Highest Possible Content is CUI'"
  echo "  > $ProgName set /opt/path/to/kibana-7.8.0-darwin-x86_64 '#BD271E' 'This page contains dynamic content -- Highest Possible Content is SECRET//NOFORN'"
  echo "  > $ProgName remove \$KIB_HOME"
  echo ""
} 

command_remove(){
  case $1 in
    "" | "-h" | "--help")
      echo "$ProgName remove <kibana_dir>"
      echo "  <kibana_dir> - Path Kibana. Usually \$KIB_HOME."
      ;; *)
      css_dir="$1/built_assets/css/"
      if [ -f "$css_dir/core.dark.css.bak" ] && [ -f "$css_dir/core.light.css.bak" ]; then
        rm "$css_dir/core.dark.css"
        rm "$css_dir/core.light.css"
        mv "$css_dir/core.dark.css.bak" "$css_dir/core.dark.css"
        mv "$css_dir/core.light.css.bak" "$css_dir/core.light.css"
        echo "Banner removed."
      else
        echo "No existing banner to remove."
      fi
  esac
}

set_banner(){
  command_remove $1
  css_dir="$1/built_assets/css/"
  cp "$css_dir/core.dark.css" "$css_dir/core.dark.css.bak"
  cp "$css_dir/core.light.css" "$css_dir/core.light.css.bak"
  echo "$(core_append $2 "$3")" >> "$css_dir/core.dark.css"
  echo "$(core_append $2 "$3")" >> "$css_dir/core.light.css"
  echo "Banner added."
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
      set_banner "$@"
      ;;
  esac
}

subcommand=$1
case $subcommand in
  "" | "-h" | "--help")
    command_help
    ;;
  *)
  shift
  command_${subcommand} "$@"
  if [ $? = 127 ]; then
    echo "Error: '$subcommand' is not a known subcommand." >&2
    echo "  Run '$ProgName --help' for a list of known subcommands." >&2
  fi
  ;;
esac
