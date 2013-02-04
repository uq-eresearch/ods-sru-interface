require 'spec_helper'

describe University do

  describe '.name' do
    subject { described_class.method(:name) }

    context "if UNIVERSITY_NAME env var is not set" do
      before { ENV.delete 'UNIVERSITY_NAME' }

      it "should have a default value" do
        subject.call.should be == 'The University of Queensland'
      end
    end

    context "if UNIVERSITY_NAME env var is set" do
      before do
        ENV['UNIVERSITY_NAME'] = 'The University of Wooloomooloo'
      end

      it "should have that value" do
        subject.call.should be == ENV['UNIVERSITY_NAME']
      end
    end

  end

  describe '.uri' do

    subject { described_class.method(:uri) }

    context "if UNIVERSITY_URI env var is not set" do
      before { ENV.delete 'UNIVERSITY_URI' }

      it "should have a default value" do
        subject.call.should be == 'http://uq.edu.au/'
      end
    end

    context "if UNIVERSITY_URI env var is set" do
      before do
        ENV['UNIVERSITY_URI'] = 'http://example.test'
      end

      it "should have that value" do
        subject.call.should be == ENV['UNIVERSITY_URI']
      end
    end

  end


end
