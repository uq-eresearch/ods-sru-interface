class OrgUnit < ActiveRecord::Base

  self.table_name = 'org_unit'

  if ENV.key?('ODS_DATABASE_URL')
    establish_connection \
      Rails::Application::Configuration.database_environment_from_database_url(
        ENV['ODS_DATABASE_URL']
      )
  end

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
      "%s <%s>" % [email_address, words.join(" ")]
    end
  end

  # Prevent creation of new records and modification to existing records
  def readonly?
    ENV.key?('ODS_DATABASE_URL')
  end

  # Prevent objects from being destroyed
  def before_destroy
    raise ActiveRecord::ReadOnlyRecord if readonly?
  end

end
