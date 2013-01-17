require 'spec_helper'

describe StaffAnonymousIdentifier do

  subject { StaffAnonymousIdentifier.find_or_create_by_staff_id('1234') }

  it { should respond_to(:staff_id, :to_s) }

  it "should produce a string identifier" do
    subject.to_s.should match(/^#{StaffAnonymousIdentifier::STRING_PREFIX}:/i)
    subject.to_s.should end_with subject.anonymous_id
  end

  it "should use HMAC-SHA1 and ENV['STAFF_ID_SECRET'] to generate identifier" do
    # Secret is from spec_helper.rb, and staff ID is 1234
    subject.to_s.should match(/2d0860ea3fff139770182c0d71de7f4de9dfccf6$/)
  end

end
