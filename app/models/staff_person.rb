class StaffPerson < ActiveRecord::Base
  include OdsModelMixin
  self.select_db

  self.table_name = 'stf_person'
end
