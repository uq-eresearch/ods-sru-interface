class CreateStaffAnonymousIdentifiers < ActiveRecord::Migration
  def change
    create_table :staff_anonymous_identifiers do |t|
      t.string :staff_id,       :limit => 12, :null => false
      t.string :anonymous_id,   :limit => 32, :null => false, :unique => true
      t.timestamps
    end
  end
end
