require 'spec_helper'

describe StaffPerson do
  it { should respond_to(:staff_id, :anonymous_identifier) }
end
