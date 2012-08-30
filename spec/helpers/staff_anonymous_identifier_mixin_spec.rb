require 'spec_helper'

describe StaffAnonymousIdentifierMixin do

  subject do
    Struct.new(:staff_id).new.extend(StaffAnonymousIdentifierMixin)
  end

  it "should handle nil values" do
    subject.staff_id = nil
    subject.anonymous_identifier.should be_nil
  end

  it "should produce a stable, anonymous identifier" do
    # Test creation
    subject.staff_id = "32354"
    anon_id_1 = subject.anonymous_identifier.to_s
    subject.staff_id = "21342"
    anon_id_2 = subject.anonymous_identifier.to_s

    # Test basic uniqueness
    anon_id_1.should_not == anon_id_2

    # Test that it's reproducable
    subject.staff_id = "32354"
    subject.anonymous_identifier.to_s.should == anon_id_1
    subject.staff_id = "0032354"
    subject.anonymous_identifier.to_s.should == anon_id_1
    subject.staff_id = "21342"
    subject.anonymous_identifier.to_s.should == anon_id_2
  end

end