class StaffPerson < ActiveRecord::Base
  extend Forwardable
  include OdsModelMixin
  include StaffAnonymousIdentifierMixin
  self.select_db

  self.table_name = 'stf_person'

  def_delegator :anonymous_identifier, :urn, :identifier

  alias_attribute :family_name, :last_name_mixed

  def given_names
    first_names.split(/\s+/)
  end

  class RifCsRepresentation

    def initialize(staff_person)
      @person = staff_person
    end

    def to_s
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.registryObjects('xmlns' => namespace) {
          xml.registryObject(:group => group) {
            xml.key @person.identifier
            xml.originatingSource group
            xml.party(:type => 'person') {
              xml.identifier(@person.identifier, :type => 'AU-QU')
              primary_name(xml)
              alt_name(xml)
              email(xml)
            }
          }
        }
      end
      builder.to_xml
    end

    private

    def namespace
      'http://ands.org.au/standards/rif-cs/registryObjects'
    end

    def group
      'The University of Queensland ODS'
    end

    def e(xml, e_name, type, value)
      return if value.nil?
      xml.send(e_name, value, :type => type)
    end

    def primary_name(xml)
      xml.name(:type => 'primary') {
        e(xml, :namePart, 'family', @person.family_name)
        @person.given_names.each do |given_name|
          e(xml, :namePart, 'given', given_name)
        end
        e(xml, :namePart, 'title', @person.title)
      }
    end

    def alt_name(xml)
      return if @person.preferred_name.nil?
      xml.name(:type => 'alternative') {
        e(xml, :namePart, 'family', @person.family_name)
        e(xml, :namePart, 'given', @person.preferred_name)
      }
    end

    def email(xml)
      return if @person.email.nil?
      # Build the location element
      xml.location {
        xml.address {
          xml.electronic(:type => 'email') {
            xml.value @person.email
          }
        }
      }
    end

  end

  def to_rif
    RifCsRepresentation.new(self).to_s
  end


end
