require 'spec_helper'

require 'idzebra'

describe SruController do

  def run_server
    begin
      pid = fork do
        # Replace forked process with our server
        exec "zebrasrv -v none -f config/zebra/yazserver.xml"
      end
      # Wait up to one second for socket to be created
      (0..20).each do
        break if File.exists?('tmp/zebra.sock')
        sleep 0.05
      end
      # Yield for block
      yield
    ensure
      # Send kill signal
      Process.kill "TERM", pid
      # Wait for termination, otherwise it will become a zombie process
      Process.wait pid
    end
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
      'version' => '1.1',
      'operation' => 'searchRetrieve',
      'query' => 'rec.id>0'
    }
    run_server do
      get :proxy, sru_params
      response.code.to_i.should == 200
      puts response.body
      response.body.should satisfy do |xml|
        xml =~ /<zs:numberOfRecords>(\d+)<\/zs:numberOfRecords>/
      end
      $1.to_i.should == 1
    end
  end

end
