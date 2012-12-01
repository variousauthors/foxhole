module Foxhole

  def Foxhole.logger
    @logger ||= Logger.new(STDOUT)

  end

  def Foxhole.backup(options={})
    logger.debug('in backup')
    logger.debug('  options' + options.inspect)
    logger.debug('  options' + options[:d])
    
    string_h = options[:d]
    # look in the .foxhole and see if today's date is there
    logger.debug('  hello: ' + string_h.nil?.to_s)
    backup_dir(string_h)
    backup_dir(options[:d]).mkpath unless backup_dir.exist?
    logger.debug('  made dir')


    # copy the sessionstore.js into that directory along with
    # a timestamp sessionstore_828928928.js

    timestamp = Time.now.utc.to_time.iso8601.gsub('-', '').gsub(':', '')
    FileUtils.cp(sessionstore, backup_dir + "sessionstore_#{timestamp}.js")
    logger.debug('out backup')
  end

  # overwrite the current sessionstore.js with the most
  # recent backup (or a particular backup)
  def Foxhole.restore
    # find the most recent folder by sorting them and taking the last
    recent_backup = Pathname.new(backup_dir.parent)
    recent_backup = recent_backup + recent_backup.entries.sort.last

    # then find the most recent backup by the same method
    recent_backup = recent_backup + recent_backup.entries.sort.last

    FileUtils.cp(recent_backup, sessionstore)
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

  def Foxhole.backup_dir(directory)
    logger.debug('in backup_dir')
    @@backup_dir ||= begin
      if directory.nil?
        logger.debug('dir was nil')
        datetime = DateTime::now
        backup_date = "#{datetime.year}.#{datetime.month}.#{datetime.day}"
        backup_dir = Pathname.new(File.expand_path(config[:backup_dir])) + backup_date
      else
        backup_dir = Pathname.new(File.expand_path(config[:backup_dir])) + directory
        logger.debug('backup: ' + backup_dir.to_path)
      end

      backup_dir
    end
  end

  def Foxhole.sessionstore
    @@sessionstore ||= Pathname.new(File.expand_path(config[:profile_dir])) + "sessionstore.js"
  end

  def Foxhole.render(sessionstore)

    JSON::parse(sessionstore)
  end
end
