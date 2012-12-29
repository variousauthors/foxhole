module Foxhole

  module EXIT_CODES
    SESSIONSTORE_MISSING = 2
    NAME_DATE_CONFLICT = 3
    BACKUP_MISSING = 4

  end

  def Foxhole.logger
    @logger ||= Logger.new(STDOUT)

  end

  def Foxhole.backup(options={})
    logger.debug('in backup')
    logger.debug('options ' + options.inspect)
    logger.debug('options[:n] ' + options[:n].to_s)

    # look in the .foxhole and ensure that today's date is there
    # TODO so weird that I can't use backup_dir(options[:name]).mkpath
    backup_dir(options[:name])

    backup_dir.mkpath unless backup_dir.exist?
    logger.debug('  backing up to: ' + backup_dir.to_path)

    # copy the sessionstore.js into that directory along with
    # a timestamp sessionstore_828928928.js

    timestamp = Time.now.utc.to_time.iso8601.gsub('-', '').gsub(':', '')
    puts backup_dir.class
    begin
      FileUtils.cp(sessionstore, backup_dir + "sessionstore_#{timestamp}.js")
    rescue Errno::ENOENT
      exit(SESSIONSTORE_MISSING)
    end
    logger.debug('out backup')
  end

  # overwrite the current sessionstore.js with the most
  # recent backup (or a particular backup)
  def Foxhole.restore(options={})
    logger.debug('in restore')
    if options[:n] && options[:d]
      # OK so right now this is being handled as an error condition, but I would
      # rather handle it in PRE and have GLI call the help banner... but I couldn't
      # figure out how to do that
      exit(NAME_DATE_CONFLICT)
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

    logger.debug("salient_backup_dir: " + salient_backup_dir.inspect)

    # then find the most recent backup or the backup matching the given time
    begin
      salient_backup = Pathname.new(salient_backup_dir) + salient_backup_dir.entries.sort.last
    rescue Errno::ENOENT
      exit(BACKUP_MISSING)
    end

    FileUtils.cp(salient_backup, sessionstore)
    logger.debug('in out')
  end

  def Foxhole.config(global_options = {})
    # configure Foxhole with the given set of global options

    # foxhole will get the profile directory from firefox's the profiles.ini file
    @@config ||= begin
                   profile = IniParse.parse( File.read(File.expand_path(global_options[:config] + "profiles.ini")) )
                   profile.each do |section|
                     if section["Name"] == global_options[:profile]
                       global_options[:profile] = global_options[:config] + section["Path"]
                     end
                   end

                   global_options
                 end
  end

  # returns a pathname object that points to the given directory,
  # or to the directory with the most recent date
  def Foxhole.backup_dir(directory=nil)
    logger.debug("in backup_dir with: ")
    logger.debug("  directory: " + directory.to_s)
    logger.debug("  foxhole: " + config[:foxhole].to_s)
    @@backup_dir ||= begin
      if directory.nil?
        logger.debug('dir was nil, using date')
        datetime = DateTime::now
        backup_date = datetime.strftime("%Y.%m.%d")

        backup_dirpath = Pathname.new(File.expand_path(config[:foxhole])) + backup_date
      else
        backup_dirpath = Pathname.new(File.expand_path(config[:foxhole])) + directory
        logger.debug('backup_dirpath: ' + backup_dirpath.to_path)
      end

      backup_dirpath
    end
  end

  def Foxhole.sessionstore
    @@sessionstore ||= Pathname.new(File.expand_path(config[:profile])) + "sessionstore.js"
  end

  def Foxhole.render(sessionstore)

    JSON::parse(sessionstore)
  end
end
