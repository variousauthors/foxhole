module Foxhole

  def Foxhole.logger
    @logger ||= Logger.new(STDOUT)

  end

  def Foxhole.backup(options={})
    logger.debug('in backup')
    logger.debug('options ' + options.inspect)
    logger.debug('options[:n] ' + options[:n])
    logger.debug('backup_dir' + backup_dir(options[:n]).to_path)

    # TODO super weird: I can't run backup_dir(options[:n]).mkpath for some reason

    # look in the .foxhole and see if today's date is there
    backup_dir.mkpath unless backup_dir.exist?
    logger.debug('  backing up to: ' + backup_dir.to_path)

    # copy the sessionstore.js into that directory along with
    # a timestamp sessionstore_828928928.js

    timestamp = Time.now.utc.to_time.iso8601.gsub('-', '').gsub(':', '')
    FileUtils.cp(sessionstore, backup_dir + "sessionstore_#{timestamp}.js")
    logger.debug('out backup')
  end

  # overwrite the current sessionstore.js with the most
  # recent backup (or a particular backup)
  def Foxhole.restore(options={})
    logger.debug('in restore')
    if options[:n] && options[:d]
      puts "Restoring by name conflicts with restoring by date\n \
              run foxhole restore with either -n or -d but not both"
      return
    end

    salient_backup_dir = if options[:n]
                           backup_dir(options[:n])
                         elsif options[:d]
                           # first parse the date time
                           datetime = DateTime.parse(options[:d])
                           backup_date = datetime.strftime("%Y.%m.%d")

                           # then pass it to backup_dir as a name
                           backup_dir(backup_date)

                         else
                           logger.debug('options :n nil')
                           # find the most recent folder by sorting them and taking the last
                           foxhole_dirs = Pathname.new(backup_dir.parent).entries

                           logger.debug('foxhole_dirs: ' + foxhole_dirs.inspect)
                           chronological_dirs = foxhole_dirs.select do |item| 
                             logger.debug('item: ' + item.to_path.inspect)
                             nil != (item.to_path =~ /^\d{4}\.\d{2}\.\d{2}$/)
                           end
                           logger.debug('chronological_dirs: ' + chronological_dirs.inspect)

                           Pathname.new(backup_dir.parent) + chronological_dirs.sort.last
                         end

    puts "salient_backup_dir: " + salient_backup_dir.inspect

    # then find the most recent backup or the backup matching the given time
    salient_backup = Pathname.new(salient_backup_dir) + salient_backup_dir.entries.sort.last

    FileUtils.cp(salient_backup, sessionstore)
    logger.debug('in out')
  end

  def Foxhole.config
    # currently the only config is the random string firefox uses
    # as your profile directory
    #
    # later on we can parse firefox/profiles.ini to get the random
    # string

    { :profile_dir => "~/.mozilla/firefox/32zkg1d3.default",
      :backup_dir => "~/.foxhole" }
  end

  # returns a pathname object that points to the given directory,
  # or to the directory with the most recent date
  def Foxhole.backup_dir(directory=nil)
    logger.debug('in backup_dir with ' + directory.to_s)
    @@backup_dir ||= begin
      if directory.nil?
        logger.debug('dir was nil, using date')
        datetime = DateTime::now
        backup_date = datetime.strftime("%Y.%m.%d")

        backup_dirpath = Pathname.new(File.expand_path(config[:backup_dir])) + backup_date
      else
        backup_dirpath = Pathname.new(File.expand_path(config[:backup_dir])) + directory
        logger.debug('backup_dirpath: ' + backup_dirpath.to_path)
      end

      backup_dirpath
    end
  end

  def Foxhole.sessionstore
    @@sessionstore ||= Pathname.new(File.expand_path(config[:profile_dir])) + "sessionstore.js"
  end

  def Foxhole.render(sessionstore)

    JSON::parse(sessionstore)
  end
end
