require 'spec_helper'

describe StaffAnonymousIdentifier do

  subject { StaffAnonymousIdentifier.create(:staff_id => '1234') }

  it { should respond_to(:staff_id, :to_s) }

  it "should produce a string identifier" do
    StaffAnonymousIdentifier.create(:staff_id => '1234')
    subject.to_s.should match(/^#{StaffAnonymousIdentifier::STRING_PREFIX}:/i)
  end

end
