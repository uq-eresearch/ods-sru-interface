require 'spec_helper'

describe Grant do
  it { should respond_to(:project_title, :anonymous_identifier) }
end
