class StaffPlacement < ActiveRecord::Base
  include OdsModelMixin
  include StaffAnonymousIdentifierMixin
  self.select_db

  self.table_name = 'stf_placement'

  belongs_to :person,
    :class_name => 'StaffPerson',
    :foreign_key => 'staff_id'

  belongs_to :org_unit,
    :class_name => 'OrgUnit',
    :foreign_key => 'org_unit_id'

end
