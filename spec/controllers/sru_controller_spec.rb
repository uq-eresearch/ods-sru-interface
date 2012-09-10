require 'spec_helper'

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

  it "should relay queries to a zebra UNIX socket" do
    sru_params = {
      'version' => '1.1',
      'operation' => 'searchRetrieve',
      'query' => 'rec.id>0'
    }
    run_server do
      get :proxy, sru_params
      response.code.should == "200"
      response.body.should \
        match(/<zs:numberOfRecords>\d+<\/zs:numberOfRecords>/)
    end
  end

end
