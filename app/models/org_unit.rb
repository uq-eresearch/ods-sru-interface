class OrgUnit < ActiveRecord::Base
  include OdsModelMixin
  self.select_db

  self.table_name = 'org_unit'

  def identifier
    "urn:uq-org-unit:#{org_unit_id}"
  end

  def address_lines
    (1..4).map{ |i| self.send(("main_address_%d" % i).to_sym) }
  end

  def email
    return nil if unit_email.nil?
    words = unit_email.split(/\s+/)
    email_address = nil
    words.each do |word|
      email_address = word if word =~ /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i
    end
    # Remove email address now we've found it
    words.delete(email_address)
    # Remove HTML tags
    words = words.map{|w| Sanitize.clean(w).strip }
    # Remove empty strings
    words.delete("")
    if words.empty?
      email_address
    else
      "%s <%s>" % [words.join(" "), email_address]
    end
  end

  def to_rif
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.registryObjects(
        'xmlns' => 'http://ands.org.au/standards/rif-cs/registryObjects') {
        xml.registryObject(:group => 'The University of Queensland ODS') {
          xml.key identifier
          xml.originatingSource ''
          xml.party(:type => 'group') {
            xml.identifier(identifier, :type => 'AU-QU')
            xml.name {
              xml.namePart [
                unit_prefix, unit_name, unit_suffix].compact.join(' ')
            }
            xml.location {
              xml.address {
                xml.physical(:type => 'streetAddress') {
                  address_lines.each do |line|
                    xml.addressPart(line, :type => 'addressLine')
                  end
                  xml.addressPart(unit_phone, :type => 'telephoneNumber') \
                    unless unit_phone.nil?
                  xml.addressPart(unit_fax, :type => 'faxNumber') \
                    unless unit_fax.nil?
                }
              }
              unless email.nil?
                xml.address {
                  xml.electronic(:type => 'email') {
                    xml.value email
                  }
                }
              end
            }
          }
        }
      }
    end
    builder.to_xml
  end

end
