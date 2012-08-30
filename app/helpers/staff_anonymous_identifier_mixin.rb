module StaffAnonymousIdentifierMixin

  def anonymous_identifier
    return nil if staff_id.nil?
    unpadded_id = staff_id.gsub(/^0*/,'')
    StaffAnonymousIdentifier.find_or_create_by_staff_id(unpadded_id)
  end

end