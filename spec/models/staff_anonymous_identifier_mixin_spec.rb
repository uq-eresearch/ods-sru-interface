require 'spec_helper'

describe StaffAnonymousIdentifierMixin do

  class StaffAnonymousIdentifierMixinTestObject < Struct.new(:staff_id)
    include StaffAnonymousIdentifierMixin
  end

  subject { StaffAnonymousIdentifierMixinTestObject.new }

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
    anon_id_1.should_not be == anon_id_2

    # Test that it's reproducable
    subject.staff_id = "32354"
    subject.anonymous_identifier.to_s.should be == anon_id_1
    subject.staff_id = "0032354"
    subject.anonymous_identifier.to_s.should be == anon_id_1
    subject.staff_id = "21342"
    subject.anonymous_identifier.to_s.should be == anon_id_2
  end

  it "should allow objects to be found using the identifier" do
    # Test creation
    subject.staff_id = "32354"
    anon_id_1 = subject.anonymous_identifier

    staff_id = "32354"
    subject.class.should_receive(:find_by_staff_id)\
      .with(kind_of(Array)).once.and_return(subject)

    subject.class.find_by_anonymous_identifier(anon_id_1.to_s).should == subject
  end

end