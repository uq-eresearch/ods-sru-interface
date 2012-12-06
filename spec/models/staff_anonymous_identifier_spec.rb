require 'spec_helper'

describe StaffAnonymousIdentifier do

  subject { StaffAnonymousIdentifier.find_or_create_by_staff_id('1234') }

  it { should respond_to(:staff_id, :to_s) }

  it "should produce a string identifier" do
    subject.to_s.should match(/^#{StaffAnonymousIdentifier::STRING_PREFIX}:/i)
    subject.to_s.should end_with subject.anonymous_id
  end

  it "should generate anonymous IDs from the STAFF_ID_SALT" do
    subject.anonymous_id.should match(/^[0-9a-f]{40}$/)
    require 'digest'
    sha1 = Digest::SHA1.new
    sha1 << subject.staff_id
    sha1 << ENV['STAFF_ID_SALT']
    subject.anonymous_id.should be == sha1.hexdigest
  end

end
