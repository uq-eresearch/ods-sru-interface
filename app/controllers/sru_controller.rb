class SruController < ApplicationController

  def proxy
    resp = proxy_query_to_socket(request.query_string)
    render :text => resp.body,
      :status => resp.code.to_i,
      :content_type => resp.content_type
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
    return resp
  end

end
