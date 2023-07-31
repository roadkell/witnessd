#!/bin/sh
#
# Generate systemd service and path units to watch files/dirs for changes and
# execute things when they are detected.

echo "Warning! This script has no safety/sanity checks. Use at your own risk."
echo "Path to be watched: $1"
echo "Executable to invoke (path must be in systemd format, e.g. %h/.local/bin/myscript.sh): $2"

service_unit=$(systemd-escape --path --template path-watcher@.service "$1")
path_unit=$(systemd-escape --path --template path-watcher@.path "$1")
exec_path="$2"
dropins_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/${service_unit}.d"
dropin_conf="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/${service_unit}.d/${exec_path##*/}.conf"

shift 2
echo "Additional arguments for the executable: $*"
echo "Systemd service unit file: ${service_unit}"
echo "Systemd path unit file: ${path_unit}"
echo "Systemd service drop-ins directory: ${dropins_dir}"
echo "Systemd service drop-in config file: ${dropin_conf}"
echo "Creating drop-in directory and config file..."

set -o noclobber
# mkdir "${dropins_dir}"
cat << EOF # > "${dropin_conf}"
# ${dropin_conf}
[Unit]
Description="Run an executable when local path gets modified"

[Service]
Environment=PATH_WATCHER_EXEC="${exec_path}"
Environment=PATH_WATCHER_ARGS="$@"
EOF

echo "Done!"
echo "Enabling systemd service and path units..."

# systemctl --user enable "${service_unit}"
# systemctl --user enable --now "${path_unit}"

echo "Done!"
