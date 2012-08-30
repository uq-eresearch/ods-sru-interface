require 'spec_helper'

describe OdsModelMixin do

  class TestObject < Struct.new(:some_field)
    include OdsModelMixin
  end

  subject { TestObject.new }

  describe "when ODS database is specified" do

    before(:each) { ENV['ODS_DATABASE_URL'] = 'sqlite3://:memory:' }
    after(:each)  { ENV.delete('ODS_DATABASE_URL') }

    it "should make object read-only" do
      subject.readonly?.should == true
    end

    it "should prevent destruction" do
      lambda { subject.before_destroy }.should raise_error
    end

  end

  describe "when no ODS database is specified" do

    it "should not make object read-only" do
      subject.readonly?.should == false
    end

    it "should not prevent destruction" do
      lambda { subject.before_destroy }.should_not raise_error
    end

  end

end