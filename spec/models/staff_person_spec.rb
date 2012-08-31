require 'spec_helper'

describe StaffPerson do
  it { should respond_to(:staff_id, :anonymous_identifier) }

  it "should output RIF-CS with :to_rif" do
      subject.staff_id = "98773"
      subject.last_name_mixed = "Atkins"
      subject.first_names = "Thomas Francis"
      subject.preferred_name = "Tommy"
      subject.title = "Mr"
      subject.email = "t.atkins@uq.edu.au"

      require 'open-uri'
      schema_location = 'http://services.ands.org.au' +
        '/documentation/rifcs/schema/registryObjects.xsd'
      schema_doc = Nokogiri::XML(open(schema_location), url = schema_location)
      schema = Nokogiri::XML::Schema.from_document(schema_doc)

      doc = Nokogiri::XML(subject.to_rif)
      # Check that the generated document validates
      schema.validate(doc).should == []

      # Check all the relevant values are in the document
      ns_decl = {'rif' => 'http://ands.org.au/standards/rif-cs/registryObjects'}
      doc.at_xpath('//rif:key', ns_decl).content.should \
        == subject.anonymous_identifier.urn
      doc.at_xpath('//rif:identifier', ns_decl).content.should \
        == subject.anonymous_identifier.urn
      primary_name = doc.at_xpath('//rif:name[@type="primary"]', ns_decl)
      primary_name.at_xpath('rif:namePart[@type="family"]', ns_decl)\
        .content.should == "Atkins"
      primary_name.at_xpath('rif:namePart[@type="given"][1]', ns_decl)\
        .content.should == "Thomas"
      primary_name.at_xpath('rif:namePart[@type="given"][2]', ns_decl)\
        .content.should == "Francis"
      primary_name.at_xpath('rif:namePart[@type="title"]', ns_decl)\
        .content.should == "Mr"
      alt_name = doc.at_xpath('//rif:name[@type="alternative"]', ns_decl)
      alt_name.at_xpath('rif:namePart[@type="family"]', ns_decl)\
        .content.should == "Atkins"
      alt_name.at_xpath('rif:namePart[@type="given"]', ns_decl)\
        .content.should == "Tommy"
    end
end
