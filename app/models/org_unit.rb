require 'rifcs_registry_object_mixin'

class OrgUnit < ActiveRecord::Base
  include OdsModelMixin
  include RifcsRepresentationMixin
  self.select_db

  self.table_name = 'org_unit'

  has_many :staff_positions,
    :class_name => 'StaffPlacement',
    :foreign_key => 'org_unit_id',
    :conditions => { :current_placement_flag => 'Y' }

  has_many :staff,
    :through => :staff_positions,
    :source => :person

  def identifier
    "uq-org-unit:#{org_unit_id}"
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

  class RifCsRepresentation

    def initialize(org_unit)
      @org_unit = org_unit
    end

    def to_doc
      build.doc
    end

    def to_s
      build.to_xml
    end

    private

    def build
      Nokogiri::XML::Builder.new do |xml|
        xml.registryObjects('xmlns' => namespace) {
          xml.registryObject(:group => group) {
            xml.key @org_unit.identifier
            xml.originatingSource group
            xml.party(:type => 'group') {
              xml.identifier(@org_unit.identifier, :type => 'AU-QU-local')
              name(xml)
              location(xml)
              parent_relation(xml)
            }
          }
        }
      end
    end

    def namespace
      'http://ands.org.au/standards/rif-cs/registryObjects'
    end

    def group
      'The University of Queensland ODS'
    end

    def name(xml)
      xml.name(:type => 'primary') {
        xml.namePart [
          @org_unit.unit_prefix,
          @org_unit.unit_name,
          @org_unit.unit_suffix].compact.join(' ')
      }
    end

    def location(xml)
      # Check if we need this element
      return if [
        @org_unit.address_lines.empty?,
        @org_unit.unit_phone.nil?,
        @org_unit.unit_fax.nil?,
        @org_unit.email.nil?,
        @org_unit.unit_url.nil?].all?
      # Build the location element
      xml.location {
        physical(xml)
        email(xml)
        url(xml)
      }
    end

    def physical(xml)
      return if @org_unit.unit_phone.nil? and
        @org_unit.unit_fax.nil? and @org_unit.address_lines.empty?
      xml.address {
        xml.physical(:type => 'streetAddress') {
          @org_unit.address_lines.each do |line|
            addressPart(xml, 'addressLine', line)
          end
          addressPart(xml, 'telephoneNumber', @org_unit.unit_phone)
          addressPart(xml, 'faxNumber', @org_unit.unit_fax)
        }
      }
    end

    def addressPart(xml, type, value)
      return if value.nil?
      xml.addressPart(value, :type => type)
    end

    def email(xml)
      electronic_address(xml, 'email', @org_unit.email)
    end

    def url(xml)
      electronic_address(xml, 'url', @org_unit.unit_url)
    end

    def electronic_address(xml, type, value)
      return if value.nil?
      xml.address {
        xml.electronic(:type => type) {
          xml.value value
        }
      }
    end

    def parent_relation(xml)
      xml.relatedObject {
        xml.key(university_uri_identifier)
        xml.relation(:type => 'isPartOf')
      }
    end

    def university_uri_identifier
      ENV['UNIVERSITY_URI_IDENTIFIER'] || 'http://uq.edu.au/'
    end

  end

  def to_rif
    RifCsRepresentation.new(self).to_s
  end

end
