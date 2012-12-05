class AlterStaffAnonymousIdentifiersToUseSha1 < ActiveRecord::Migration
  def up
    StaffAnonymousIdentifier.delete_all
    # Remove the exist column
    remove_column :staff_anonymous_identifiers, :anonymous_id
    # Replace with column big enough for SHA1
    add_column :staff_anonymous_identifiers, :anonymous_id, :string,
      :limit => 40, :null => false, :unique => true, :default => ''
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Can't recover the deleted IDs"
  end
end
