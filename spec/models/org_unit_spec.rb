require 'spec_helper'

describe OrgUnit do

  subject { OrgUnit.new }

  it "email property provides a sanitized version of unit_email property" do
    subject.unit_email = " t.user@uq.edu.au "
    subject.email.should == "t.user@uq.edu.au"

    subject.unit_email = \
      "Executive Assistant <br> Test User <br> t.user@uq.edu.au"
    subject.email.should == "t.user@uq.edu.au <Executive Assistant Test User>"
  end

end
