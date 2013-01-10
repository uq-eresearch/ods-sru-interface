require 'spec_helper'

require 'idzebra'
require 'rack/test'

require File.join(File.dirname(__FILE__), '..', '..', 'app')

describe 'Application' do
  include Rack::Test::Methods

  def app
    App
  end

  def run_server
    begin
      cleanup_zebra_socket_file
      # Get PID of started server
      pid = fork do
        # Replace forked process with our server
        exec "zebrasrv -v none -f config/zebra/yazserver.xml"
      end
      # Wait up to one second for socket to be created
      20.times do
        break if socket_exists?
        sleep 0.05
      end
      raise "Socket doesn't exist!" unless socket_exists?
      # Yield for block
      yield
    ensure
      # Send kill signal
      Process.kill "TERM", pid
      # Wait for termination, otherwise it will become a zombie process
      Process.wait pid
      # Do cleanup
      cleanup_zebra_socket_file
    end
  end

  def cleanup_zebra_socket_file
    # Remove current socket file if it exists
    File.unlink('tmp/zebra.sock') if socket_exists?
  end

  def socket_exists?
    File.exists?('tmp/zebra.sock')
  end

  before(:each) do
    IdZebra::log_level = :warn
    IdZebra::API('config/zebra/zebra.cfg') do |repo|
      person = StaffPerson.new
      person.assign_attributes({
          :staff_id => "98773",
          :last_name_mixed => "Atkins",
          :first_names => "Thomas Francis",
          :preferred_name => "Tommy",
          :title => "Mr",
          :email => "t.atkins@uq.edu.au"
        }, :without_protection => true)
      person.save
      repo.init
      repo.add_record(person.to_rif)
      repo.commit
    end
  end

  it "should relay queries to a zebra UNIX socket" do
    sru_params = {
      'version' => '1.2',
      'operation' => 'searchRetrieve',
      'query' => 'rec.id>0'
    }
    run_server do
      get '/sru', sru_params
      last_response.should be_ok
      last_response.body.should satisfy do |xml|
        xml =~ /<zs:numberOfRecords>(\d+)<\/zs:numberOfRecords>/
      end
      $1.to_i.should == 1
    end
  end

end
