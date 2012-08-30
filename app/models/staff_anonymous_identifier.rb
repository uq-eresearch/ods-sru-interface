class StaffAnonymousIdentifier < ActiveRecord::Base

  URN_PREFIX = 'uq-staff-ref'

  attr_accessible :staff_id
  before_create :create_anonymous_id

  def to_s
    anonymous_id
  end

  def urn
    "urn:#{URN_PREFIX}:#{anonymous_id}"
  end

  private

  def create_anonymous_id
    while (random_hex = SecureRandom.hex(16))
      break if StaffAnonymousIdentifier.find_by_anonymous_id(random_hex).nil?
    end
    self.anonymous_id = random_hex
  end

end