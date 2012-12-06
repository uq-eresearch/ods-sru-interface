class StaffAnonymousIdentifier < Struct.new(:staff_id, :anonymous_id)

  STRING_PREFIX = 'uq-staff-ref'
  DB_PREFIX = self.name.dasherize

  def to_s
    "#{STRING_PREFIX}:#{anonymous_id}"
  end

  class << self

    def find_by_anonymous_id(anonymous_id)
      find(anonymous_id)
    end

    def find_or_create_by_staff_id(staff_id)
      anonymous_id = generate_anonymous_id(staff_id)
      find(anonymous_id) or create(staff_id, anonymous_id)
    end

    def generate_anonymous_id(staff_id)
      digest = sha1_algo
      digest << staff_id
      digest << ENV['STAFF_ID_SALT']
      digest.hexdigest
    end

    private

    def find(anonymous_id)
      staff_id = redis.get("#{DB_PREFIX}:#{anonymous_id}")
      staff_id and new(staff_id, anonymous_id)
    end

    def create(staff_id, anonymous_id = generate_anonymous_id(staff_id))
      redis.set("#{DB_PREFIX}:#{anonymous_id}", staff_id)
      new(staff_id, anonymous_id)
    end

    def redis
      @@redis ||= case Rails.env
        when 'test'
          MockRedis.new
        else
          Redis.new(:path => "./tmp/redis.sock")
        end
    end

    def sha1_algo
      begin
        require 'openssl'
        algo = OpenSSL::Digest::SHA1.new
      rescue LoadError
        algo = Digest::SHA1.new
      end
    end
  end

end
