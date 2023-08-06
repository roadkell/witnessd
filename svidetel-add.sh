#!/bin/sh
#
# Generate systemd service and path units for Svidetel, and add them
# to user's local systemd configuration

echo "svidetel-add: generate systemd service and path units, and add them to user's local systemd config"
echo "Warning! This script has no safety/sanity checks. Use at your own risk."
echo
echo "Path to be watched: $1"
echo "Executable to invoke (path in systemd format, e.g. %h/.local/bin/myscript.sh): $2"

service_unit=$(systemd-escape --path --template svidetel@.service "$1")
path_unit=$(systemd-escape --path --template svidetel@.path "$1")
exec_path="$2"
user_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/"
dropins_dir="${user_config_dir}${service_unit}.d"
dropin_conf="${user_config_dir}${service_unit}.d/${exec_path##*/}.conf"

shift 2
echo "Additional arguments for the executable: $*"
echo "Systemd service unit file: ${service_unit}"
echo "Systemd path unit file: ${path_unit}"
echo "Systemd local user config directory: ${user_config_dir}"
echo "Systemd service drop-ins directory: ${dropins_dir}"
echo "Systemd service drop-in config file: ${dropin_conf}"
echo

set -o noclobber

echo "Copying Svidetel template units to systemd local user config dir..."

cp svidetel@.service "${user_config_dir}"
cp svidetel@.path "${user_config_dir}"

echo "Done!"
echo "Creating drop-in directory and config file..."

mkdir "${dropins_dir}"
cat << EOF > "${dropin_conf}"
# ${dropin_conf}
[Unit]
Description="Run an executable when local path gets modified"

[Service]
Environment=SVIDETEL_EXEC="${exec_path}"
Environment=SVIDETEL_ARGS="$@"
EOF

echo "Done!"
echo "Enabling systemd service and path units..."

systemctl --user enable "${service_unit}"
systemctl --user enable --now "${path_unit}"

echo "Done!"
