foxhole.rb(1) -- backup and restore Firefox sessionstores
=========================================================


## SYNOPSIS
foxhole [--version] [--help]
        backup [--name] | restore [--name|--date]

## DESCRIPTION

**Foxhole** protects your tab groups from Firefox crashes, stupid mistakes,
and clandestine users. You can use the foxhole commandline utility to make
quick and easy backups or your "sessionstore" file, and restore it just as
easily in case of problems. The sessionstore file is what Firefox uses to
keep track of all those tabs you have open, and while Firefox does maintain
its own backups, tab groups are important enough to warrent extra care.

By default, foxhole keeps backups in a folder named ".foxhole" in your
home directory. These backups are kept in chronological order, within folders
named for the date of the backup. Foxhole uses YYYY.MM.DD as its date format,
so that they folders can easily be grouped by year or sorted chronologically.

### EXIT STATUS
  * 1: exit with problems (some... problems)
  * 2: sessionstore file couldn't be located in the firefox user's profile directory.
  * 3: --name and --date were used in combination, which is not OK.
  * 4: given the commandline options, no appropriate backup file could be found.

## OPTIONS

### GLOBAL OPTIONS
  * `--version`:
    Prints the Foxhole suite version number that the foxhole program came from.
  * `--help`:
    Prints the synopsis and a lits of foxhole commands. Both the backup and
    restore commands accept the --help option, which displays the synopsis
    and options specific to those commands.

### BACKUP OPTIONS
  * `--name=NAME`:
    Backs up the current sessionstore under a particular name. This name can
    be used later to restore the session out of chronological order. This way
    a savvy user can make special custom session stores for sharing with other
    users, or to partition different browsing sessions.

### RESTORE OPTIONS
  * `--name=NAME`:
    Restores the most recent sessionstore backed up with the given name. If no
    such sessionstore exists, then foxhole will fail. Note that this will always
    restore the most recent sessionstore with the given name: if more than
    one sessionstore has been backed up under the same name, and some older
    sessionstore file is desired, then this option must be combined with --hour.
  * `--date=DATE`:
    Date and Name are mutually exclusive. By default restore restores the most
    recently saved session store. If given a particular date, it will instead
    attempt to restore the most recent sessionstore file backed up on the given
    date. As above, if the date given does not exist in the foxhole directory,
    then nothing will come of this. Also similar to --name, if a particular
    sessionstore from the given date is desired, then this option should be
    combined with --hour.

    The given date is parsed with Ruby's DateTime::parse method. The format
    recommended by the help banner is YYYY/MM/DD, but this is not necessary.
    The parse method used will recognize dates in many formats: try a few to
    see!
  * `--hour=HOUR`:
    Oh unimplemented!
  * `-t`, `--tabula-rasa`:
    Also unimplemented.

## EXAMPLES

Backup the current sessionstore

  $ foxhole backup

Create a backup with a given name

  $ foxhole backup --name=special_name

Restore from that backup

  $ foxhole restore --name=special_name

Restore a particular sessionstore saved under the given name

  $ foxhole restore --name=special_name --hour="20:59:25"

Blank the sessionstore.

  $ foxhole restore -t

## EXIT STATUS

## FILES

`~/.foxhole/` is the default home of the sessionstore backups.

## AUTHOR

This app was made by various authors.

