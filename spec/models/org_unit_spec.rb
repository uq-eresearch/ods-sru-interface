require 'spec_helper'

describe OrgUnit do

  subject { OrgUnit.new }

  it "should provide all the address lines as a single property" do
    subject.main_address_1 = "Room 304, Level 3"
    subject.main_address_2 = "Building No. 8"
    subject.main_address_3 = "Ipswich Campus"
    subject.main_address_4 = "11 Salisbury Road, Ipswich, Qld, 4305"

    subject.address_lines.tap do |a|
      a[0].should == subject.main_address_1
      a[1].should == subject.main_address_2
      a[2].should == subject.main_address_3
      a[3].should == subject.main_address_4
    end
  end

  it "should provide a sanitized version of unit_email property" do
    subject.unit_email = " t.user@uq.edu.au "
    subject.email.should == "t.user@uq.edu.au"

    subject.unit_email = \
      "Executive Assistant <br> Test User <br> t.user@uq.edu.au"
    subject.email.should == "Executive Assistant Test User <t.user@uq.edu.au>"
  end

end
