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

  it "should output RIF-CS with :to_rif" do
    subject.org_unit_id = 15
    subject.main_address_1 = "Room 304, Level 3"
    subject.main_address_2 = "Building No. 8"
    subject.main_address_3 = "Ipswich Campus"
    subject.main_address_4 = "11 Salisbury Road, Ipswich, Qld, 4305"
    subject.unit_email = \
      "Executive Assistant <br> Test User <br> t.user@uq.edu.au"

    require 'open-uri'
    schema_location = 'http://services.ands.org.au' +
      '/documentation/rifcs/schema/registryObjects.xsd'
    schema_doc = Nokogiri::XML(open(schema_location), url = schema_location)
    schema = Nokogiri::XML::Schema.from_document(schema_doc)

    doc = Nokogiri::XML(subject.to_rif)
    # Check that the generated document validates
    schema.validate(doc).should == []

    doc.at('key').content.should \
      match(/#{subject.org_unit_id}$/)
  end

end
