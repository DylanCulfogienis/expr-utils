#!/bin/sh

ProgName=$(basename $0)

core_append(){
  cat << EOF

/* BEGIN EXPR BANNER */
html::before,html::after {
  background-color: $1;
  color: $2;
  content: "$3";
  position: fixed;
  padding: 2px;
  z-index: 99999999;
  width: 100%;
  text-align: center;
  font-weight: bold;
}
html::before {
  top: 0;
  box-shadow: 0 2px 2px -1px rgba(152, 162, 179, 0.3), 0 1px 5px -2px rgba(152, 162, 179, 0.3);
}
html::after {
  bottom: 0;
  box-shadow: 0 -2px 2px -1px rgba(152, 162, 179, 0.3), 0 -1px 5px -2px rgba(152, 162, 179, 0.3);
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
  shift
  echo "$(core_append "$@")" >> "$css_dir/core.dark.css"
  echo "$(core_append "$@")" >> "$css_dir/core.light.css"
  echo "Banner added."
}

command_set(){
  case $1 in
    "" | "-h" | "--help")
      echo "$ProgName set <kibana_dir> <background_color> <text_color> <message>"
      echo "  <kibana_dir> - Path Kibana. Usually \$KIB_HOME."
      echo "  <background_color> - a valid CSS3 color, applied to banner background. Recommend using either '#54B399' (<= CUI) or '#BD271E' (>= SECRET)."
      echo "  <text_color> - a valid CSS3 color, applied to banner content text. Recommend using either 'auto' or 'white'."
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
