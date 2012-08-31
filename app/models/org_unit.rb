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

  class RifCSRepresentation

    def initialize(org_unit)
      @org_unit = org_unit
    end

    def to_s
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.registryObjects(
          'xmlns' => 'http://ands.org.au/standards/rif-cs/registryObjects') {
          xml.registryObject(:group => 'The University of Queensland ODS') {
            xml.key @org_unit.identifier
            xml.originatingSource ''
            xml.party(:type => 'group') {
              xml.identifier(@org_unit.identifier, :type => 'AU-QU')
              name(xml)
              xml.location {
                physical(xml)
                email(xml)
                url(xml)
              } if has_location?
            }
          }
        }
      end
      builder.to_xml
    end

    private

    def name(xml)
      xml.name {
        xml.namePart [
          @org_unit.unit_prefix,
          @org_unit.unit_name,
          @org_unit.unit_suffix].compact.join(' ')
      }
    end

    def physical(xml)
      return if @org_unit.unit_phone.nil? and
        @org_unit.unit_fax.nil? and @org_unit.address_lines.empty?
      xml.address {
        xml.physical(:type => 'streetAddress') {
          @org_unit.address_lines.each do |line|
            xml.addressPart(line, :type => 'addressLine')
          end
          xml.addressPart(@org_unit.unit_phone, :type => 'telephoneNumber') \
            unless @org_unit.unit_phone.nil?
          xml.addressPart(@org_unit.unit_fax, :type => 'faxNumber') \
            unless @org_unit.unit_fax.nil?
        }
      }
    end

    def email(xml)
      return if @org_unit.email.nil?
      xml.address {
        xml.electronic(:type => 'email') {
          xml.value @org_unit.email
        }
      }
    end

    def url(xml)
      return if @org_unit.unit_url.nil?
      xml.address {
        xml.electronic(:type => 'url') {
          xml.value @org_unit.unit_url
        }
      }
    end

    def has_location?
      not [@org_unit.address_lines.empty?,
        @org_unit.unit_phone.nil?,
        @org_unit.unit_fax.nil?,
        @org_unit.email.nil?,
        @org_unit.unit_url.nil?].all?
    end

  end

  def to_rif
    RifCSRepresentation.new(self).to_s
  end

end
