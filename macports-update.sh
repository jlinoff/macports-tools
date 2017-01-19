#!/bin/bash
#
# Update my macports installation.
#
# It assumes that macports is installed in /opt/macports/latest.
#
# I run this daily.
#
# License: MIT Open Source.
# Copyright (c) 2017 by Joe Linoff

# ================================================================
# Includes
# ================================================================
Location="$(cd $(dirname $0) && pwd)"
source $Location/macports-utils.sh

# ================================================================
# Functions
# ================================================================
function help() {
    Base=$(basename $0)
    cat <<EOF

USAGE
    ${Base} [OPTIONS]

DESCRIPTION
    Update macports installation in /opt/macports/latest.

    Run it whenever you want to update your macports packages.
    I run it several times per week.

    You can, of course, just run "port sync" or "port upgrade outdated"
    yourself.

OPTIONS
    -h, --help          This help message.

    -p PATH, --path PATH
                        Use a different path for the port program.
                        The default path is $PortProg
                        

    -V, --version       Display the program version number and exit.

EXAMPLES
    # Example 1: get help.
    \$ $Base -h

    # Example 2: update
    \$ $Base

EOF
    exit 0
}

# ================================================================
# Main
# ================================================================
PortProg='/opt/macports/latest/bin/port'
Version='0.1'

while (( $# )) ; do
    arg="$1"
    shift
    case "$arg" in
        -h|--help)
            help
            ;;
        -p|--path)
            PortProg="$1"
            ;;
        -V|--version)
            echo "$0 $Version"
            exit 0;;
        *)
            err "Unrecognized argument: $arg"
            ;;
    esac
done

info "Updating the local macports installation."
Dts=$(date +'%Y%m%d-%H%M%S')
Backup="~/tmp/port-pkgs.txt-$Dts"
info "Backing up installed packages to $Backup."
runcmd sudo ${PortProg} installed requested '>' $Backup

# Sync and update.
runcmd sudo ${PortProg} sync
runcmdst 0 1 sudo ${PortProg} upgrade outdated
runcmdst 0 1 sudo ${PortProg} uninstall inactive

info "done"
