require 'nokogiri'

module RifcsRepresentationMixin

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def all_with_related
      all
    end

    # By using an enumerator, we can avoid having all the XML documents
    # in memory.
    def rifcs_document_enum
      Enumerator.new do |y|
        self.all_with_related.each do |p|
          y << self::RifCsRepresentation.new(p).to_doc
        end
      end
    end

    def to_rif
      doc = self.rifcs_document_enum.reduce do |d, o|
        d.root << o.root.children
        d
      end
      # Ensure everything is in the same namespace
      doc.root.children.each {|n| n.namespace = n.parent.namespace}
      doc.to_xml
    end

  end

end
