class GrantInvestigator < ActiveRecord::Base
  include OdsModelMixin
  self.select_db

  self.table_name = 'grt_investigator'
end
