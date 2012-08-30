require 'spec_helper'

describe StaffAnonymousIdentifier do

  subject { StaffAnonymousIdentifier.create(:staff_id => '1234') }

  it { should respond_to(:staff_id, :to_s, :urn) }

  it "should produce a valid URN" do
    StaffAnonymousIdentifier.create(:staff_id => '1234')
    subject.urn.should match(/^urn:#{StaffAnonymousIdentifier::URN_PREFIX}:/i)
  end

end
