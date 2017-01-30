# macports-tools
Contains tools for installing and updating macports.

I use these tools pretty frequently and thought that others might find them useful.

The available tools are defined in the table below.

| Tool | Description |
| ---- | ----------- |
| macports-install.sh | Installs a new version of macports in /opt/macports/VERSION and creates the /opt/macports/latest link. |
| macports-update.sh | Updates the macports installation in /opt/macports/latest. |

The `macports-utils.sh` script is simply a set of commonly used functions that work in bash 3.x (the default on the Mac).

Each tool has a help option (-h or --help) that provides more detailed information about the tool capabilities.

### Help for macports-installer.sh

```bash
$ ./macports-install.sh -h

USAGE
    macports-install.sh [OPTIONS] <MACPORTS-VERSION>

DESCRIPTION
    This tool installs macports in /opt/macports and
    sets the /opt/macports/latest link.

    It only needs to be used when the macports base is updated.

    I use the -f (--fix) option to modify the settings to use
    HTTP instead of port 873 on work Mac because port 873 is
    blocked by the firewall.

OPTIONS
    -d DIR, --dir DIR   The installation directory.
                        The default is /opt/macports.

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
    $ macports-install.sh -h

    # Example 2: install macports 2.3.5 in /opt/macports/2.3.5
    $ macports-install.sh 2.3.5

    # Example 3: install macports 2.3.5 in /opt/macports/2.3.5 with no prompt.
    $ macports-install.sh -n 2.3.5

    # Example 4: install macports 2.3.5 in /opt/macports/2.3.5 with no prompt, use HTTP (-f)
    $ macports-install.sh -f -n 2.3.5

    # Example 5: install macports 2.3.5 in a custom directory: /opt/tmp/macports/2.3.5
    #            with no prompt, use HTTP (-f)
    $ macports-install.sh -f -n -d /opt/tmp/macports 2.3.5
```

### Help for macports-update.sh

```bash
$ ./macports-update.sh -h

USAGE
    macports-update.sh [OPTIONS]

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
                        The default path is /opt/macports/latest/bin/port
                        

    -V, --version       Display the program version number and exit.

EXAMPLES
    # Example 1: get help.
    $ macports-update.sh -h

    # Example 2: update
    $ macports-update.sh

```
