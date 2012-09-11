require 'rifcs_registry_object_mixin'

class Grant < ActiveRecord::Base
  include OdsModelMixin
  include RifcsRepresentationMixin
  self.select_db

  self.table_name = 'grt_project'

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

  end

  def to_rif
    RifCsRepresentation.new(self).to_s
  end
end
