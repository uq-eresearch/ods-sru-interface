class StaffPerson < ActiveRecord::Base
  extend Forwardable
  include OdsModelMixin
  include StaffAnonymousIdentifierMixin
  self.select_db

  self.table_name = 'stf_person'

  has_many :positions,
    :class_name => 'StaffPlacement',
    :foreign_key => 'staff_id',
    :conditions => { :current_placement_flag => 'Y' }

  has_many :org_units,
    :through => :positions

  def_delegator :anonymous_identifier, :urn, :identifier

  alias_attribute :family_name, :last_name_mixed

  def given_names
    first_names.split(/\s+/)
  end

  class RifCsRepresentation

    def initialize(staff_person)
      @person = staff_person
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
            xml.key @person.identifier
            xml.originatingSource group
            xml.party(:type => 'person') {
              xml.identifier(@person.identifier, :type => 'AU-QU')
              email_identifier(xml)
              primary_name(xml)
              alt_name(xml)
              email(xml)
              related_objects(xml)
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

    def email_identifier(xml)
      return if @person.email.nil?
      xml.identifier('mailto:%s' % @person.email, :type => 'uri')
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

    def related_objects(xml)
      begin
        @person.org_units.each do |ou|
          xml.relatedObject {
            xml.key(ou.identifier)
            xml.relation(:type => 'isMemberOf')
          }
        end
      rescue ActiveRecord::UnknownPrimaryKey
        # Ignore possible incomplete relationships
      end
    end

  end

  def self.to_rif
    StaffAnonymousIdentifier.update_cache
    doc = includes(:org_units).all.map do |p|
      RifCsRepresentation.new(p).to_doc
    end.reduce do |d, o|
      d.root << o.root.children
      d
    end
    # Ensure everything is in the same namespace
    doc.root.children.each {|n| n.namespace = n.parent.namespace}
    doc.to_xml
  end

  def to_rif
    RifCsRepresentation.new(self).to_s
  end


end
