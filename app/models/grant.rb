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

  def project_code
    rm_project_code.gsub(/^0+/, '')
  end

  def identifier
    "urn:uq-grant-code:#{project_code}"
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
              xml.identifier(@grant.identifier, :type => 'AU-QU')
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
      xml.name {
        xml.namePart @grant.project_title
      }
    end

    def internal_participant_keys
      begin
        @grant.investigators.internal.map do |i|
          i.staff_person.identifier
        end.compact
      rescue ActiveRecord::UnknownPrimaryKey
        []
      end
    end

    def external_participant_keys
      begin
        @grant.investigators.external.map { |i| i.key }
      rescue ActiveRecord::UnknownPrimaryKey
        []
      end
    end

    def related_objects(xml)
      (internal_participant_keys | external_participant_keys).each do |k|
        xml.relatedObject {
          xml.key(k)
          xml.relation(:type => 'isParticipant')
        }
      end
    end

  end

  def to_rif
    RifCsRepresentation.new(self).to_s
  end
end
