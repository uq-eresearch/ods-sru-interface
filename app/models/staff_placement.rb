class StaffPlacement < ActiveRecord::Base
  include OdsModelMixin
  include StaffAnonymousIdentifierMixin
  self.select_db

  self.table_name = 'stf_placement'
end
