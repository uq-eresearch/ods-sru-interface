require 'rifcs_registry_object_mixin'

class GrantInvestigator < ActiveRecord::Base
  include OdsModelMixin
  include StaffAnonymousIdentifierMixin
  include RifcsRepresentationMixin
  extend Forwardable
  self.select_db

  self.table_name = 'grt_investigator'
  self.primary_key = :investigator_id

  belongs_to :grant,
    :class_name => 'Grant',
    :foreign_key => 'rm_project_code'

  belongs_to :staff_person,
    :class_name => 'StaffPerson',
    :foreign_key => 'staff_id'

  # Note that unmatched staff IDs won't be covered by either
  scope :internal, joins(:staff_person)
  scope :external, where("investigator_id NOT IN (%s)" %
    internal.select(:investigator_id).to_sql)

  def_delegator :self, :surname, :family_name

  def key
    "uq-grant-investigator:%s" % rm_person_code
  end

  def given_names
    given_name.nil? ? [] : given_name.split(/\s+/)
  end

  class RifCsRepresentation

    def initialize(grant_investigator)
      @person = grant_investigator
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
            xml.key @person.key
            xml.originatingSource group
            xml.party(:type => 'person') {
              primary_name(xml)
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

  end

  def self.all_with_related
    # Only get unique external persons
    GrantInvestigator.external.where(
      :investigator_id =>
        GrantInvestigator.external\
          .select("min(investigator_id)")\
          .group(:rm_person_code))
  end

  def to_rif
    return staff_person.to_rif unless staff_person.nil?
    RifCsRepresentation.new(self).to_s
  end

end
