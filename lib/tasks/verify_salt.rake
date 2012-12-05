desc 'Checks salt will always generate a unique ID in the Staff ID range.'
task :verify_salt do
  require 'dbm'
  require 'bloomfilter-rb'
  require 'digest'

  abort "Env variable STAFF_ID_SALT is missing!" unless ENV.key? 'STAFF_ID_SALT'
  secret = ENV['STAFF_ID_SALT']
  @count = 0

  def all_staff_ids
    column_digits = 7
    1.upto(10**column_digits-1).each do |i|
      yield i.to_s
    end
  end

  LOOKUP_DB = 'hash_test'
  @db = DBM.new(LOOKUP_DB, 600, DBM::NEWDB)

  begin
    require 'openssl'
    STDERR.puts "Using OpenSSL SHA1."
    algo = OpenSSL::Digest::SHA1.new
  rescue LoadError
    STDERR.puts "Using Ruby SHA1."
  end

  at_exit do
    @db.close
    @bf.stats
  end

  trap('INT') do
    puts "\nChecked #{@count} hashes \"#{secret}\" before interrupt."
    exit 1
  end

  counter = Fiber.new do
    loop do
      print "\r #{@count} IDs checked"
      printed_at = Time.now.to_f
      while Time.now.to_f - printed_at < 0.1
        Fiber.yield
      end
    end
  end

  def new?(v)
    @bf ||= BloomFilter::Native.new :size => 2**28
    if @bf.include? v
      return false if @db.has_key? v
    end
    @bf.insert v
    @db[v] = true
    @count += 1
    true
  end

  all_staff_ids do |id|
    algo << id
    algo << secret
    hash = algo.hexdigest
    algo.reset
    raise StopIteration unless new? hash
    counter.resume
  end

  sleep(0.1)
  counter.resume
  # at_exit should trigger
end

