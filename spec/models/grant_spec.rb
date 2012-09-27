require 'spec_helper'

describe Grant do
  it { should respond_to(:project_title) }

  it "should output RIF-CS with :to_rif" do
      subject.rm_project_code = "00098773"
      subject.project_title = "Rats, Bats & Vats"
      subject.scheme_name_primary = "ARC Discovery Projects"
      subject.grantor_reference = "RN1234567"

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
      unpadded_project_code = subject.rm_project_code.gsub(/^0+/,'')
      doc.at_xpath('//rif:key', ns_decl).content.should \
        match(/#{unpadded_project_code}$/)
      doc.at_xpath('//rif:activity', ns_decl)['type'].should == 'project'
      doc.at_xpath('//rif:identifier', ns_decl).content.should \
        match(/#{unpadded_project_code}$/)
      doc.xpath('//rif:identifier', ns_decl).map{|n| n.content}.should \
        == ["urn:uq-grant-code:%d" % subject.rm_project_code.to_i,
            "http://purl.org/au-research/grants/arc/%s" %
            subject.grantor_reference]
      doc.at_xpath('//rif:name/rif:namePart', ns_decl).content.should \
        == subject.project_title
    end
end
