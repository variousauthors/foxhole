require 'foxhole/version'
require 'foxhole/commands'
require 'logger'


# OK so all this really needs to do is copy the sessionstore.js files
# in firefox to some nice backup like .foxhole/
#
# There they will be organized by date in folders 2011.11.21/
#
# DESCRIPTION
#   Backup or restore your firefox tab groups (panoramas)
#
#   -b --backup
#             archives your current session store, saving all your precious
#             panoramas to as safe location (default)
#
#   -r --restore
#             overwrites your current session store with the most recent
#             backup
#
# TODO currently, after restoring, firefox always opens minimized...
#       even if the sessionstore had the maximized state set. How
#       very strange

require 'pathname'
require 'fileutils'
require 'time'

# Add requires for other files you add to your project here, so
# you just need to require this one file in your bin file
