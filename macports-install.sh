#!/bin/bash
#
# Install macports on a Mac.
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
# CLI help.
function help() {
    Base=$(basename $0)
    cat <<EOF

USAGE
    ${Base} [OPTIONS] <MACPORTS-VERSION>

DESCRIPTION
    This tool installs macports in $InstallDir and
    sets the $InstallDir/latest link.

    It only needs to be used when the macports base is updated.

    I use the -f (--fix) option to modify the settings to use
    HTTP instead of port 873 on work Mac because port 873 is
    blocked by the firewall.

OPTIONS
    -d DIR, --dir DIR   The installation directory.
                        The default is $InstallDir.

    -f, --fix           Fix to use HTTP instead of port 873.

    -h, --help          This help message.

    -n, --no-prompt     Do not prompt the user to continue.
                        Use this for batch scripts.

    -o, --overwrite     Overwrite the installation directory.
                        Normally the program aborts if the
                        directory exists. Be careful with this
                        option, you could overwrite a valid
                        installation.

    -V, --version       Display the program version number and exit.

EXAMPLES
    # Example 1: get help.
    \$ $Base -h

    # Example 2: install macports 2.3.5 in /opt/macports/2.3.5
    \$ $Base 2.3.5

    # Example 3: install macports 2.3.5 in /opt/macports/2.3.5 with no prompt.
    \$ $Base -y 2.3.5

    # Example 4: install macports 2.3.5 in /opt/macports/2.3.5 with no prompt, use HTTP (-f)
    \$ $Base -f -y 2.3.5

    # Example 5: install macports 2.3.5 in a custom directory: /opt/tmp/macports/2.3.5
    #            with no prompt, use HTTP (-f)
    \$ $Base -f -y -d /opt/tmp/macports 2.3.5

EOF
    exit 0
}


# ================================================================
# Main
# ================================================================
Version='0.1'
MacportsVersion=""
InstallDir='/opt/macports'
Fix=0
Prompt=1
Overwrite=0
Cli="$0 $*"

# Parse the command line options.
while (( $# > 0 )) ; do
    arg="$1"
    shift
    case "$arg" in
        -d|--dir)
            InstallDir="$1"
            shift
            ;;
        -f|--fix)
            Fix=1
            ;;
        -h|--help)
            help
            ;;
        -n|--no-prompt)
            Prompt=0
            ;;
        -o|--overwrite)
            Overwrite=1
            ;;
        -V|--version)
            echo "$0 $Version"
            exit 0;;
        -*)
            err "Unrecognized argument: $arg"
            ;;
        *)
            MacportsVersion="$arg"
            ;;
    esac
done

# Argument checks/setup.
if [[ "$MacportsVersion" == "" ]] ; then
    err 'Macports version not specified. Cannot continue. See -h for more information.'
fi

MacportsTarfile="MacPorts-2.3.5.tar.bz2"
MacportsURL="https://github.com/macports/macports-base/releases/download/v$MacportsVersion/$MacportsTarfile"
MacportsInstallDir=$InstallDir/$MacportsVersion
MacportsLatestDir=$InstallDir/latest
PortProg="$MacportsLatestDir/bin/port"
WorkDir="$MacportsInstallDir/work"
SrcDir=$(echo "$MacportsTarfile" | sed -e 's/\.tar.bz2//')
BuildDir="$WorkDir/$SrcDir"
FixMsg='Use port 873 for updates.'
if (( Fix )) ; then FixMsg='Use HTTP for updates.' ; fi

# Report what we are going to do.
cat <<EOF

Installation Parameters

   Host               : $(hostname)
   Date               : $(date)
   User               : $(whoami)
   Location           : $(pwd)
   Command            : $Cli

   InstallDir         : $InstallDir
   MacportsInstallDir : $MacportsInstallDir
   MacportsLatestDir  : $MacportsLatestDir
   MacportsVersion    : $MacportsVersion
   MacportsTarfile    : $MacportsTarfile
   MacportsURL        : $MacportsURL
   PortProg           : $PortProg
   WorkDir            : $WorkDir
   BuildDir           : $BuildDir
   Fix                : $FixMsg

EOF

# Prompt if needed.
Run=0
if (( Prompt )) ; then
    Continue="timeout"
    echo "Please check the installation parameters carefully."
    read -t 60 -p 'Continue (Y/N) <N>? ' Continue
    echo
    if [[ "$Continue" == "timeout" ]] ; then
        err "continue prompt timed out, exiting"
    fi
    case "$Continue" in
        y|Y|yes|YES)
            Run=1
            ;;
        *)
            ;;
    esac
else
    Run=1
fi

if (( Run == 0 )) ; then exit 0 ; fi


# Do not overwrite an existing installation. Make the user do it.
if [ -d "$MacportsInstallDir" ] ; then
    if (( Overwrite )) ; then
        warn "macports already installed in $MacportsInstallDir.\n\tIt will be overwritten."
        runcmd sudo rm -rf $MacportsInstallDir
    else
        if (( Prompt )) ; then
            warn "macports already installed in $MacportsInstallDir.\n\tYou must delete it to proceed."
            Continue='n'
            read -t 60 -p 'Overwrite (Y/N) <N>? ' Continue
            case "$Continue" in
                y|Y|yes|YES)
                    info 'Overwriting...'
                    runcmd sudo rm -rf $MacportsInstallDir
                    ;;
                *)
                    exit 0
                    ;;
            esac
        else
            err "macports already installed in $MacportsInstallDir.\n\tYou must delete it to proceed.\n\tUse -o to overwrite it."
        fi
    fi
fi

# ================================================================
# Install macports.
# ================================================================
info 'Installing.'

# Step 1. Get the packages that are currently installed, if macports is
#         present on the system.
PortsListFile=''
if [ -f "$PortProg" ] ; then
    PortsListFile="/tmp/ports-$$.list"
    info "Get the packages that are currently installed."
    runcmd $PortProg installed requested '>' $PortsListFile
fi

# Step 2. Do the base installation.
#         Note: could use curl here, doesn't make a difference.
runcmd sudo mkdir -p $WorkDir
runcmd pushd $WorkDir
runcmd sudo wget --no-check-certificate $MacportsURL
runcmd sudo tar jxf $MacportsTarfile
runcmd cd $BuildDir
runcmd sudo ./configure --prefix=$MacportsInstallDir
runcmd sudo make
runcmd sudo make install
runcmd popd

# Step 3. Create the latest link
runcmd pushd $MacportsInstallDir
[ -f latest ] && runcmd sudo rm -f latest || true
runcmd sudo ln -s $MacportsInstallDir $MacportsLatestDir
runcmd popd

# Step 4. Configure to use HTTP if the user specified --fix.
if (( Fix )) ; then
    runcmd pushd $MacportsInstallDir
    info "Updating to use HTTP intead of port 873."
    runcmd cd etc/macports
    runcmd sudo cp sources.conf{,.orig}
    runcmd sudo sed -i -e "'s/^rsync:/#rsync:/'" sources.conf
    runcmd sudo chmod 0666 sources.conf
    runcmd sudo echo "'http://distfiles.macports.org/ports.tar.gz [default]'" '>>' sources.conf
    runcmd sudo chmod 0644 sources.conf
    runcmd popd
fi

# Step 5. Update the ports infrastructure.
runcmd sudo $MacportsInstallDir/bin/port sync
runcmdst 0 1 sudo $MacportsInstallDir/bin/port upgrade outdated

# Step 6. Update
if [[ ! "$PortsListFile" == "" ]] ; then
    info "Updated the packages."
    cat $PortsListFile | grep '^ ' | grep '(active)' | awk '{print $1}' | uniq | xargs -L1 -I{} runcmd sudo $PortProg install {}
fi

info "Done."

cat <<EOF

Macports has been successfully installed on your system in
$MacportsInstallDir.

The $MacportsLastestDir link has been updated.

You can access the macports port program by updating your PATH and
MANPATH variables as follows:

   export PORT="${MacportsLastestDir}/bin:\$PATH"
   export MANPORT="${MacportsLastestDir}/share/man:\$MANPATH"

Once the path variables have been updated you can verify that
everything works by checking the version.

   \$ port version
   Version: $MacportsVersion

For more information about the macports project, please visit
https://www.macports.org.

EOF
