require 'rifcs_registry_object_mixin'

class StaffPerson < ActiveRecord::Base
  extend Forwardable
  include OdsModelMixin
  include StaffAnonymousIdentifierMixin
  include RifcsRepresentationMixin
  self.select_db

  self.table_name = 'stf_person'
  self.primary_key = :staff_id

  has_many :positions,
    :class_name => 'StaffPlacement',
    :foreign_key => 'staff_id',
    :conditions => { :current_placement_flag => 'Y' }

  has_many :grant_investigations,
    :class_name => 'GrantInvestigator',
    :foreign_key => 'staff_id'

  has_many :alternate_identifiers,
    :class_name => 'StaffAltId',
    :foreign_key => 'staff_id'

  has_many :org_units,
    :through => :positions

  has_many :grants,
    :through => :grant_investigations

  def_delegator :anonymous_identifier, :to_s, :identifier

  attr_accessor :cached_org_unit_ids, :cached_alt_ids

  alias_attribute :family_name, :last_name_mixed

  def self.identifier(staff_id)
    anon_id_by_staff_id(staff_id).to_s
  end

  def given_names
    first_names.split(/\s+/)
  end

  def alt_ids
    cached_alt_ids || alternate_identifiers.map(&:to_s)
  end

  def org_unit_ids
    cached_org_unit_ids || positions.pluck(:org_unit_id)
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
              xml.identifier(@person.identifier, :type => 'AU-QU-local')
              alternate_identifiers(xml)
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

    def alternate_identifiers(xml)
      email_identifier(xml)
      @person.alt_ids.each do |alt|
        xml.identifier(alt, :type => 'uri')
      end
    end

    def email_identifier(xml)
      return if @person.email.nil?
      xml.identifier("mailto:#{@person.email}", :type => 'uri')
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
        @person.org_unit_ids.each do |org_unit_id|
          next if org_unit_id.nil?
          xml.relatedObject {
            xml.key(OrgUnit.identifier org_unit_id)
            xml.relation(:type => 'isMemberOf')
          }
        end
      rescue ActiveRecord::UnknownPrimaryKey
        # Ignore possible incomplete relationships
      end
    end

  end

  def self.all_with_related
    alt_ids = StaffAltId.all.each_with_object({}) do |altId, h|
      (h[altId.staff_id] ||= []) << altId.to_s
    end
    placements = StaffPlacement.where(:current_placement_flag => 'Y')\
      .select([:staff_id, :org_unit_id])\
      .each_with_object({}) do |placement, h|
      (h[placement.staff_id] ||= []) << placement.org_unit_id
    end
    all.map do |sp|
      sp.cached_alt_ids = alt_ids[sp.staff_id] || []
      sp.cached_org_unit_ids = placements[sp.staff_id] || []
      sp
    end
  end

  def to_rif
    RifCsRepresentation.new(self).to_s
  end

end
