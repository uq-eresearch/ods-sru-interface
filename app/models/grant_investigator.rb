class GrantInvestigator < ActiveRecord::Base
  include OdsModelMixin
  include StaffAnonymousIdentifierMixin
  self.select_db

  self.table_name = 'grt_investigator'
end
