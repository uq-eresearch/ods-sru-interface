# Most code was generated with:
#
#   File.open('ods_schema.rb', 'w') do |f|
#     ActiveRecord::SchemaDumper.dump(OrgUnit.connection, f)
#   end

class CreateOdsTables < ActiveRecord::Migration

  def self.up
    create_table "grt_investigator", :id => false, :force => true do |t|
      t.string  "rm_project_code",    :limit => 10,  :null => false
      t.string  "rm_person_code",     :limit => 10,  :null => false
      t.integer "investigator_id",    :limit => 8
      t.integer "investigator_order", :limit => 8
      t.string  "staff_id",           :limit => 12
      t.string  "student_id",         :limit => 11
      t.string  "confidential_flag",  :limit => 1
      t.string  "surname",            :limit => 30
      t.string  "given_name",         :limit => 30
      t.string  "title",              :limit => 30
      t.string  "person_type",        :limit => 10
      t.string  "rm_proj_role_code",  :limit => 10
      t.string  "proj_role_code_alt", :limit => 10
      t.string  "proj_role_name",     :limit => 200
      t.string  "rm_aou_code",        :limit => 10
      t.string  "rm_aou_name",        :limit => 200
      t.integer "org_unit_id",        :limit => 8
      t.string  "rm_ext_org_code",    :limit => 10
      t.string  "ext_org_code_alt",   :limit => 12
      t.string  "ext_org_name",       :limit => 200
      t.string  "ext_org_abbrev",     :limit => 20
    end

    add_index "grt_investigator", ["rm_project_code", "rm_person_code"],
      :name => "grt_investigator_pk", :unique => true
    add_index "grt_investigator", ["rm_project_code"],
      :name => "fki_grt_investigator_rm_project_code"

    create_table "grt_project", :id => false, :force => true do |t|
      t.string   "rm_project_code",                :limit => 10,  :null => false
      t.string   "project_title",                  :limit => 200
      t.string   "confidential_flag",              :limit => 1
      t.datetime "date_applied"
      t.datetime "date_approved"
      t.datetime "date_rejected"
      t.datetime "date_withdrawn"
      t.datetime "date_combined"
      t.datetime "date_transferred"
      t.datetime "project_start_date"
      t.datetime "project_end_date"
      t.datetime "closed_off_date"
      t.string   "grantor_reference",              :limit => 20
      t.string   "rm_proj_status_code",            :limit => 10
      t.string   "proj_status_code_alt",           :limit => 10
      t.string   "proj_status_name",               :limit => 200
      t.string   "admin_rm_aou_code",              :limit => 10
      t.string   "admin_rm_aou_name",              :limit => 200
      t.integer  "admin_org_unit_id",              :limit => 8
      t.string   "contact_rm_person_code",         :limit => 10
      t.string   "contact_staff_id",               :limit => 12
      t.string   "contact_surname",                :limit => 30
      t.string   "contact_given_name",             :limit => 30
      t.string   "contact_title",                  :limit => 30
      t.string   "rm_activity_type_code",          :limit => 10
      t.string   "activity_type_code_alt",         :limit => 10
      t.string   "activity_type_name",             :limit => 200
      t.string   "rm_funding_type_code",           :limit => 10
      t.string   "funding_type_code_alt",          :limit => 10
      t.string   "funding_type_name",              :limit => 200
      t.string   "rm_proj_entry_code",             :limit => 10
      t.string   "proj_entry_code_alt",            :limit => 10
      t.string   "proj_entry_name",                :limit => 200
      t.string   "rm_scheme_code_primary",         :limit => 10
      t.string   "scheme_code_alt_primary",        :limit => 12
      t.string   "scheme_name_primary",            :limit => 200
      t.string   "scheme_internal_funded_primary", :limit => 1
      t.string   "rm_funding_class_code",          :limit => 10
      t.string   "funding_class_code_alt",         :limit => 10
      t.string   "funding_class_name",             :limit => 200
    end

    add_index "grt_project", ["rm_project_code"],
      :name => "grt_project_pk", :unique => true

    create_table "org_unit", :id => false, :force => true do |t|
      t.integer  "org_unit_id",       :limit => 8,   :null => false
      t.string   "unit_prefix",       :limit => 100
      t.string   "unit_name",         :limit => 80
      t.string   "unit_suffix",       :limit => 100
      t.string   "unit_abbreviation", :limit => 100
      t.integer  "unit_type_id",      :limit => 8
      t.integer  "approval_body_id",  :limit => 8
      t.datetime "aproval_date"
      t.datetime "unit_start_date"
      t.datetime "unit_end_date"
      t.string   "main_address_1"
      t.string   "main_address_2"
      t.string   "main_address_3",    :limit => 57
      t.string   "main_address_4",    :limit => 100
      t.string   "unit_phone"
      t.string   "unit_fax"
      t.string   "unit_email"
      t.string   "unit_url"
      t.string   "unit_leader_title", :limit => 100
    end

    add_index "org_unit", ["org_unit_id"],
      :name => "org_unit_pk", :unique => true

    create_table "stf_person", :id => false, :force => true do |t|
      t.string "staff_id",          :limit => 12, :null => false
      t.string "person_type",       :limit => 8
      t.string "last_name",         :limit => 30
      t.string "last_name_mixed",   :limit => 30
      t.string "first_names",       :limit => 35
      t.string "preferred_name",    :limit => 20
      t.string "title",             :limit => 20
      t.string "name_for_headings", :limit => 40
      t.string "initials",          :limit => 6
      t.string "prior_last_name",   :limit => 30
      t.string "gender",            :limit => 6
      t.string "username",          :limit => 20
      t.string "email"
    end

    add_index "stf_person", ["staff_id"],
      :name => "stf_person_pk", :unique => true

    create_table "stf_placement", :id => false, :force => true do |t|
      t.string   "employee_no",             :limit => 12,
        :null => false
      t.string   "sort_key",                :limit => 8,
        :null => false
      t.string   "occupancy_type_code",     :limit => 7,
        :null => false
      t.string   "staff_id",                :limit => 12
      t.string   "movement_code",           :limit => 6
      t.datetime "start_date"
      t.datetime "end_date"
      t.string   "position_no",             :limit => 12
      t.integer  "stf_unit_no",             :limit => 8
      t.string   "stf_unit_name",           :limit => 50
      t.integer  "org_unit_id",             :limit => 8
      t.string   "current_placement_flag",  :limit => 1
      t.string   "employment_type_code",    :limit => 6
      t.string   "attendance_type_code",    :limit => 6
      t.string   "reporting_category_code", :limit => 6
      t.string   "placement_title",         :limit => 35
      t.string   "job_code",                :limit => 6
      t.decimal  "current_fte",  :precision => 3, :scale => 2
    end

    add_index "stf_placement",
      ["employee_no", "sort_key", "occupancy_type_code"],
      :name => "stf_placement_pk", :unique => true

    create_table "stf_alt_id", :id => false, :force => true do |t|
      t.string "staff_id",          :limit => 12, :null => false
      t.string "type",              :limit => 20, :null => false
      t.string "id",                :limit => 12, :null => false
    end

    add_index "stf_alt_id", ["type", "id"],
      :name => "stf_alt_id_pk", :unique => true
    add_index "stf_alt_id", ["staff_id"],
      :name => "stf_alt_staff_id_fk", :unique => false

  end

  def self.down
    # Not implemented
  end
end