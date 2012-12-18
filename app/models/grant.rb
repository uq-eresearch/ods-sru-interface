require 'rifcs_registry_object_mixin'

class Grant < ActiveRecord::Base
  include OdsModelMixin
  include RifcsRepresentationMixin
  self.select_db

  self.table_name = 'grt_project'
  self.primary_key = :rm_project_code

  has_many :investigators,
    :class_name => 'GrantInvestigator',
    :foreign_key => 'rm_project_code'

  scope :safe, where(:confidential_flag => 'N')

  attr_accessor :cached_internal_participant_ids

  def project_code
    rm_project_code.gsub(/^0+/, '')
  end

  def identifier
    "uq-grant-code:#{project_code}"
  end

  def internal_participant_keys
    (cached_internal_participant_ids || begin
      investigators.internal.map do |i|
        i.staff_id
      end.compact
    rescue ActiveRecord::UnknownPrimaryKey
      []
    end).map{|i| StaffPerson.identifier i}
  end

  class RifCsRepresentation

    def initialize(grant)
      @grant = grant
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
            xml.key @grant.identifier
            xml.originatingSource group
            xml.activity(:type => 'project') {
              xml.identifier(@grant.identifier, :type => 'AU-QU-local')
              grantor_identifier(xml)
              name(xml)
              related_objects(xml)
            }
          }
        }
      end
    end

    private

    def namespace
      'http://ands.org.au/standards/rif-cs/registryObjects'
    end

    def group
      'The University of Queensland ODS'
    end

    def name(xml)
      xml.name(:type => 'primary') {
        xml.namePart @grant.project_title
      }
    end

    def grantor_identifier(xml)
      uri = case @grant.scheme_name_primary
        when /^ARC/
          "http://purl.org/au-research/grants/arc/%s" %
            @grant.grantor_reference
        when /^NHMRC/
          "http://purl.org/au-research/grants/nhmrc/%s" %
            @grant.grantor_reference
        else
          nil
        end
      xml.identifier(uri, :type => 'uri') unless uri.nil?
    end

    def related_objects(xml)
      @grant.internal_participant_keys.each do |k|
        xml.relatedObject {
          xml.key(k)
          xml.relation(:type => 'hasParticipant')
        }
      end
    end

  end

  def self.all_with_related
    staff = GrantInvestigator.internal
      .select([:rm_project_code, "#{GrantInvestigator.table_name}.staff_id"])
      .each_with_object({}) do |investigator, h|
      (h[investigator.rm_project_code] ||= []) << investigator.staff_id
    end
    Grant.all.map do |grant|
      grant.cached_internal_participant_ids = staff[grant.rm_project_code] || []
      grant
    end
  end

  def to_rif
    RifCsRepresentation.new(self).to_s
  end
end
