class CreateOrgUnits < ActiveRecord::Migration
  def change
    create_table :org_units do |t|

      t.timestamps
    end
  end
end
