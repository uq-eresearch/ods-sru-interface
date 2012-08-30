require 'spec_helper'

describe OdsModelMixin do

  class TestObject < Struct.new(:some_field)
    include OdsModelMixin
  end

  subject { TestObject.new }

  describe "when ODS database is specified" do

    before(:each) { ENV['ODS_DATABASE_URL'] = 'sqlite3:///:memory:' }
    after(:each)  { ENV.delete('ODS_DATABASE_URL') }

    it "should establish a new DB connection when :select_db is called" do
      subject.class.should_receive(:establish_connection)\
        .with(kind_of(Hash)).once
      subject.class.select_db
    end

    it "should make object read-only" do
      subject.readonly?.should == true
    end

    it "should prevent destruction" do
      lambda { subject.before_destroy }.should raise_error
    end

  end

  describe "when no ODS database is specified" do

    it "should not establish a new DB connection when :select_db is called" do
      subject.class.should_not_receive(:establish_connection)\
        .with(kind_of(Hash))
      subject.class.select_db
    end

    it "should not make object read-only" do
      subject.readonly?.should == false
    end

    it "should not prevent destruction" do
      lambda { subject.before_destroy }.should_not raise_error
    end

  end

end