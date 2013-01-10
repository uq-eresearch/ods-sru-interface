class StaffAltId < ActiveRecord::Base
  extend Forwardable
  include OdsModelMixin
  self.select_db

  self.table_name = 'stf_alt_id'
  self.primary_key = :id
  self.inheritance_column = :_disable_sti

  belongs_to :staff_person,
    :class_name => 'StaffPerson',
    :foreign_key => 'staff_id'

  attr_accessible :type, :id

  def to_s
    case type
    when 'RID'
      'http://www.researcherid.com/rid/%s' % id
    else
      id
    end
  end


end