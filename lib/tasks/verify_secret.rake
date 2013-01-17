desc 'Checks secret will always generate a unique ID in the Staff ID range.'
task :verify_secret do
  require 'dbm'
  require 'bloomfilter-rb'
  require 'digest'

  unless ENV.key? 'STAFF_ID_SECRET'
    abort "Env variable STAFF_ID_SECRET is missing!"
  end
  secret = ENV['STAFF_ID_SECRET']
  @count = 0

  def all_staff_ids
    column_digits = 7
    1.upto(10**column_digits-1).each do |i|
      yield i.to_s
    end
  end

  LOOKUP_DB = 'hash_test'
  @db = DBM.new(LOOKUP_DB, 600, DBM::NEWDB)

  require 'openssl'
  STDERR.puts "Using OpenSSL HMAC SHA1."
  algo = OpenSSL::HMAC.new(secret, 'SHA1')

  at_exit do
    @db.close
    @bf.stats
    File.unlink('hash_test.db')
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
    hash = algo.hexdigest
    algo.reset
    raise StopIteration unless new? hash
    counter.resume
  end

  sleep(0.1)
  counter.resume
  # at_exit should trigger
end

