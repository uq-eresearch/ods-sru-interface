
module OdsModelMixin

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def select_db
      return unless ENV.key?('ODS_DATABASE_URL')
      establish_connection(
        database_environment_from_database_url(ENV['ODS_DATABASE_URL']))
    end

    def database_environment_from_database_url(db_url)
      # Based on how Heroku do it: https://gist.github.com/1059446
      begin
        uri = URI.parse(db_url)

        scheme = \
          case uri.scheme
          when "postgres"
            "postgresql"
          when "oracle"
            "oracle_enhanced"
          else
            uri.scheme
          end

        return {
          'adapter' => scheme,
          'database' => (uri.path || "").split("/")[1],
          'username' => uri.user,
          'password' => uri.password,
          'host' => uri.host,
          'port' => uri.port
        }
      rescue URI::InvalidURIError
        nil
      end
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
