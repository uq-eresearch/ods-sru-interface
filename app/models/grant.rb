class Grant < ActiveRecord::Base
  include OdsModelMixin
  self.select_db

  self.table_name = 'grt_project'
end
