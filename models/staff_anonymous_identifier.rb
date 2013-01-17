require 'openssl'

class StaffAnonymousIdentifier < Struct.new(:staff_id, :anonymous_id)

  STRING_PREFIX = 'uq-staff-ref'
  DB_PREFIX = self.name.dasherize

  def to_s
    "#{STRING_PREFIX}:#{anonymous_id}"
  end

  # Class Methods
  class << self

    def find_by_anonymous_id(anonymous_id)
      find(anonymous_id)
    end

    def find_or_create_by_staff_id(staff_id)
      anonymous_id = generate_anonymous_id(staff_id)
      find(anonymous_id) or create(staff_id, anonymous_id)
    end

    def generate_anonymous_id(staff_id)
      OpenSSL::HMAC.hexdigest('SHA1', secret, staff_id)
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

    def secret
      ENV['STAFF_ID_SECRET']
    end

    def redis
      @@redis ||= case secret
        when 'test_environment_secret'
          require 'mock_redis'
          MockRedis.new
        else
          require 'redis'
          Redis.new(:path => "./tmp/redis.sock")
        end
    end

  end

end
