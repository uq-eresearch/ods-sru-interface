class StaffPlacement < ActiveRecord::Base
  include OdsModelMixin
  self.select_db

  self.table_name = 'stf_placement'
end
