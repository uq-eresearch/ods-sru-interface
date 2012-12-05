class StaffAnonymousIdentifier < ActiveRecord::Base

  @@cache = {}

  STRING_PREFIX = 'uq-staff-ref'

  attr_accessible :staff_id
  before_create :create_anonymous_id

  def to_s
    "#{STRING_PREFIX}:#{anonymous_id}"
  end

  def self.cache
    @@cache
  end

  def self.update_cache
    @@cache = StaffAnonymousIdentifier.all.index_by(&:staff_id)
  end

  private

  def create_anonymous_id
    digest = sha1_algo
    digest << staff_id
    digest << ENV['STAFF_ID_SALT']
    self.anonymous_id = digest.hexdigest
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