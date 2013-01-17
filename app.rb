# Check we have a staff ID secret, because otherwise we don't have anonymous IDs
unless ENV.key? 'STAFF_ID_SECRET'
  abort "Env variable STAFF_ID_SECRET is missing!"
end

Bundler.setup
require 'sinatra'

class App < Sinatra::Application

  get '/' do
    haml :index
  end

  get '/sru' do
    resp = proxy_query_to_socket(request.query_string)
    content_type resp.content_type
    [resp.code.to_i, resp.body]
  end

  private

  def proxy_query_to_socket(query_string)
    require 'net/protocol'
    require 'net/http'
    unix_socket = Net::BufferedIO.new(Socket.unix("tmp/zebra.sock"))
    resp = nil
    begin
      # Make request to Zebra with provided query string
      req = Net::HTTP::Get.new('/')
      req.exec(unix_socket, "1.0", '?%s' % query_string)

      # Wait for and parse the Zebra HTTP response
      begin
        resp = Net::HTTPResponse.read_new(unix_socket)
      end
      resp.reading_body(unix_socket, req.response_body_permitted?) { }
    ensure
      if unix_socket.respond_to?(:close) and not unix_socket.closed?
        unix_socket.close
      end
    end
    resp
  end

end

__END__
@@ layout
%html
  %head
    %title ODS SRU Interface
  %body
    =yield

@@ index
%h1
  ODS SRU Lookup Interface
%p
  You're probably looking for the
  %a{:href => '/sru'} SRU Interface.