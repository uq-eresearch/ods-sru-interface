require 'spec_helper'

describe StaffPerson do

  it { should respond_to(:staff_id, :anonymous_identifier, :org_units) }

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
      schema.validate(doc).should be == []

      # Check all the relevant values are in the document
      ns_decl = {'rif' => 'http://ands.org.au/standards/rif-cs/registryObjects'}
      doc.at_xpath('//rif:key', ns_decl).content.should \
        be == subject.anonymous_identifier.to_s
      doc.at_xpath('//rif:party', ns_decl)['type'].should be == 'person'
      doc.at_xpath('//rif:identifier', ns_decl).content.should \
        be == subject.anonymous_identifier.to_s
      primary_name = doc.at_xpath('//rif:name[@type="primary"]', ns_decl)
      primary_name.at_xpath('rif:namePart[@type="family"]', ns_decl)\
        .content.should be == "Atkins"
      primary_name.at_xpath('rif:namePart[@type="given"][1]', ns_decl)\
        .content.should be == "Thomas"
      primary_name.at_xpath('rif:namePart[@type="given"][2]', ns_decl)\
        .content.should be == "Francis"
      primary_name.at_xpath('rif:namePart[@type="title"]', ns_decl)\
        .content.should be == "Mr"
      alt_name = doc.at_xpath('//rif:name[@type="alternative"]', ns_decl)
      alt_name.at_xpath('rif:namePart[@type="family"]', ns_decl)\
        .content.should be == "Atkins"
      alt_name.at_xpath('rif:namePart[@type="given"]', ns_decl)\
        .content.should be == "Tommy"
    end

  it "should use alternate IDs in RIF-CS" do
      subject.staff_id = "98773"
      subject.last_name_mixed = "Atkins"
      subject.first_names = "Thomas Francis"
      subject.preferred_name = "Tommy"
      subject.title = "Mr"
      subject.email = "t.atkins@uq.edu.au"
      subject.save!
      subject.alternate_identifiers.create(
        :type => 'RID',
        :id => 'XX-1234-5678'
      )

      require 'open-uri'
      schema_location = 'http://services.ands.org.au' +
        '/documentation/rifcs/schema/registryObjects.xsd'
      schema_doc = Nokogiri::XML(open(schema_location), url = schema_location)
      schema = Nokogiri::XML::Schema.from_document(schema_doc)

      doc = Nokogiri::XML(subject.to_rif)
      # Check that the generated document validates
      schema.validate(doc).should be == []

      # Check all the relevant values are in the document
      ns_decl = {'rif' => 'http://ands.org.au/standards/rif-cs/registryObjects'}
      doc.at_xpath('//rif:key', ns_decl).content.should \
        be == subject.anonymous_identifier.to_s
      doc.at_xpath('//rif:party', ns_decl)['type'].should be == 'person'
      doc.xpath('//rif:identifier', ns_decl).map{|n| n.content}.should \
        be == [subject.anonymous_identifier.to_s,
            'mailto:%s' % subject.email,
            subject.alternate_identifiers.first.to_s]
    end
end
