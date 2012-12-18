module StaffAnonymousIdentifierMixin

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    MAX_STAFF_ID_PADDING = 12

    def find_by_anonymous_identifier(anon_id)
      # Convert from URN if necessary
      anon_id = anon_id.rpartition(':').last if anon_id =~ /:/
      # Find the matching identifier
      anon_ident = StaffAnonymousIdentifier.find_by_anonymous_id(anon_id)
      return nil if anon_ident.nil?
      # Check with varying amounts of padding
      possible_ids = \
        ((anon_ident.staff_id.length)...MAX_STAFF_ID_PADDING).map do |padding|
          anon_ident.staff_id.rjust(padding, '0')
        end
      # Return nill if nothing found
      self.find_by_staff_id(possible_ids)
    end

    def anon_id_by_staff_id(staff_id)
      return nil if staff_id.nil?
      unpadded_id = staff_id.gsub(/^0*/,'')
      StaffAnonymousIdentifier.find_or_create_by_staff_id(unpadded_id)
    end

  end

  def anonymous_identifier
    self.class.anon_id_by_staff_id(staff_id)
  end

end