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
    while (random_hex = SecureRandom.hex(16))
      break if StaffAnonymousIdentifier.find_by_anonymous_id(random_hex).nil?
    end
    self.anonymous_id = random_hex
  end

end