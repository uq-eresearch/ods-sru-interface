require 'spec_helper'

describe OrgUnit do

  subject { OrgUnit.new }

  it { should respond_to(:staff) }

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
    subject.unit_prefix = "Office of the"
    subject.unit_name = "Pro-Vice-Chancellor"
    subject.unit_suffix = nil
    subject.unit_phone = "+61 (7) 9999 9999"
    subject.unit_fax = "+61 (7) 9999 9998"
    subject.unit_url = "http://example.test/"
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

    # Check all the relevant values are in the document
    ns_decl = { 'rif' => 'http://ands.org.au/standards/rif-cs/registryObjects' }
    doc.at_xpath('//rif:key', ns_decl).content.should \
      match(/#{subject.org_unit_id}$/)
    doc.at_xpath('//rif:identifier', ns_decl).content.should \
      match(/#{subject.org_unit_id}$/)
    doc.at_xpath('//rif:party', ns_decl)['type'].should == 'group'
    doc.at_xpath('//rif:name/rif:namePart', ns_decl).content.should \
      == "Office of the Pro-Vice-Chancellor"
    streetAddress = doc.at_xpath(
      '//rif:location/rif:address/rif:physical[@type="streetAddress"]',
      ns_decl)
    (1...4).each do |i|
      streetAddress.at_xpath('rif:addressPart[@type="addressLine"][%d]' % i,
        ns_decl).content.should == subject.send("main_address_#{i}".to_sym)
    end
    streetAddress.at_xpath(
      'rif:addressPart[@type="telephoneNumber"]',
      ns_decl).content.should == subject.unit_phone
    streetAddress.at_xpath(
      'rif:addressPart[@type="faxNumber"]',
      ns_decl).content.should == subject.unit_fax
    doc.at_xpath(
      '//rif:location/rif:address/rif:electronic[@type="email"]/rif:value',
      ns_decl).content.should == subject.email
  end

end
