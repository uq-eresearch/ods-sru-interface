
module OdsModelMixin

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def select_db
      return unless ENV.key?('ODS_DATABASE_URL')
      establish_connection Rails::Application::Configuration\
        .database_environment_from_database_url(
          ENV['ODS_DATABASE_URL']
        )
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