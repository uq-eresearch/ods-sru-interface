class OrgUnit < ActiveRecord::Base
  include OdsModelMixin
  self.select_db

  self.table_name = 'org_unit'

  def address_lines
    (1..4).map{ |i| self.send(("main_address_%d" % i).to_sym) }
  end

  def email
    words = unit_email.split(/\s+/)
    email_address = nil
    words.each do |word|
      email_address = word if word =~ /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i
    end
    # Remove email address now we've found it
    words.delete(email_address)
    # Remove HTML tags
    words = words.map{|w| Sanitize.clean(w).strip }
    # Remove empty strings
    words.delete("")
    if words.empty?
      email_address
    else
      "%s <%s>" % [words.join(" "), email_address]
    end
  end

end
