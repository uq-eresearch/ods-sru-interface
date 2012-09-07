class SruController < ApplicationController

  def proxy
    require 'net/protocol'
    require 'net/http'
    unix_socket = Net::BufferedIO.new(Socket.unix("tmp/zebra.sock"))
    resp = nil
    begin
      # Make request to Zebra with provided query string
      req = Net::HTTP::Get.new('/')
      req.exec(unix_socket, "1.1", '?%s' % request.query_string)

      # Wait for and parse the Zebra HTTP response
      begin
        resp = Net::HTTPResponse.read_new(unix_socket)
      end while resp.kind_of?(Net::HTTPContinue)
      resp.reading_body(unix_socket, req.response_body_permitted?) { }
    ensure
      unix_socket.close if unix_socket.respond_to?(:close)
    end
    render :text => resp.body,
      :status => resp.code.to_i,
      :content_type => resp.content_type
  end

end
