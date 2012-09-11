module RifcsRepresentationMixin

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def all_with_related
      all
    end

    def to_rif
      doc = self.all_with_related.map do |p|
        self::RifCsRepresentation.new(p).to_doc
      end.reduce do |d, o|
        d.root << o.root.children
        d
      end
      # Ensure everything is in the same namespace
      doc.root.children.each {|n| n.namespace = n.parent.namespace}
      doc.to_xml
    end

  end

end