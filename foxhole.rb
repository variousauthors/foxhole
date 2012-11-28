#!/usr/bin/env ruby

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

require 'pathname.rb'
require 'fileutils'
require 'time'

class FoxHole

  def self.backup
    # look in the .foxhole and see if today's date is there
    self.backup_dir.mkpath unless backup_dir.exist?

    # copy the sessionstore.js into that directory along with
    # a timestamp sessionstore_828928928.js

    timestamp = Time.now.utc.to_time.iso8601.gsub('-', '').gsub(':', '')
    FileUtils.cp(self.sessionstore, backup_dir + "sessionstore_#{timestamp}.js")
  end

  # overwrite the current sessionstore.js with the most
  # recent backup (or a particular backup)
  def self.restore
    # find the most recent folder by sorting them and taking the last
    recent_backup = Pathname.new(self.backup_dir.parent)
    recent_backup = recent_backup + recent_backup.entries.sort.last

    # then find the most recent backup by the same method
    recent_backup = recent_backup + recent_backup.entries.sort.last

    FileUtils.cp(recent_backup, self.sessionstore)
  end

  def self.config
    # currently the only config is the random string firefox uses
    # as your profile directory
    #
    # later on we can parse firefox/profiles.ini to get the random
    # string

    { :profile_dir => "~/.mozilla/firefox/32zkg1d3.default",
      :backup_dir => "~/.foxhole" }
  end

  def self.backup_dir
    @@backup_dir ||= (Proc.new {
      datetime = DateTime::now
      backup_date = "#{datetime.year}.#{datetime.month}.#{datetime.day}"
      backup_dir = Pathname.new(File.expand_path(config[:backup_dir])) + backup_date
    }).call # what is this javascript?
  end

  def self.sessionstore
    @@sessionstore ||= Pathname.new(File.expand_path(config[:profile_dir])) + "sessionstore.js"
  end

  def self.render(sessionstore)

    JSON::parse(self.sessionstore)
  end

end

FoxHole.backup
