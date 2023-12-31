#!/usr/bin/env bash
#
# Generate systemd service and path units for witnessd, and add them
# to user's local systemd configuration
# https://github.com/roadkell/witnessd

set -Eeuo pipefail

# Unit files will be named after the path to be watched (in systemd-escape form)
service_unit=$(systemd-escape --path --template witnessd@.service "$1")
path_unit=$(systemd-escape --path --template witnessd@.path "$1")
cmd_path="$2"
units_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/"
dropins_dir="${units_dir}${service_unit}.d"
# Drop-in config file will be named after the command to run
dropin_conf="${units_dir}${service_unit}.d/${cmd_path##*/}.conf"

echo
echo "witnessd-add: generate systemd service and path units, and add them to user's local systemd config"
echo
echo "WARNING! This script has no safety/sanity checks. Use at your own risk!"
echo
echo "Path to be watched: $1"
echo "Command to run: $2"
shift 2
echo "Additional arguments for the command: $*"
echo "Systemd service unit file: ${service_unit}"
echo "Systemd path unit file: ${path_unit}"
echo "Systemd local user config directory: ${units_dir}"
echo "Systemd service drop-ins directory: ${dropins_dir}"
echo "Systemd service drop-in config file: ${dropin_conf}"
echo

read -r -n 1 -p "Proceed? [y/N] "
if [[ $REPLY =~ ^[Yy]$ ]]; then

	set -o noclobber
	echo
	echo -n "Copying template units to systemd local user config dir... "

	cp witnessd@.service "${units_dir}"
	cp witnessd@.path "${units_dir}"

	echo "Done!"
	echo -n "Creating drop-in directory and config file... "

	mkdir "${dropins_dir}"

	cat <<EOF >"${dropin_conf}"
# ${dropin_conf}
# This file was generated by witnessd-add on $(date)
[Unit]
Description="Run a command when local path gets modified"
Documentation=https://github.com/roadkell/witnessd
[Service]
Environment=WITNESSD_CMD="${cmd_path}"
Environment=WITNESSD_ARGS="$@"
EOF

	echo "Done!"
	echo -n "Enabling systemd service and path units... "

	systemctl --user enable "${service_unit}"
	systemctl --user enable --now "${path_unit}"

	echo "Done!"

fi
