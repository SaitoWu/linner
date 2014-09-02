require "reel"
require "json"

module Linner
  class Reactor < Reel::Server::HTTP
    include Celluloid

    Celluloid.logger = nil

    attr_accessor :clients

    def initialize(host = "127.0.0.1", port = 35729)
      @clients = []
      super(host, port, &method(:on_connection))
    end

    def on_connection(connection)
      while request = connection.request
        if request.websocket?
          connection.detach
          route_websocket request.websocket
          return
        else
          route_request connection, request
        end
      end
    end

    def route_request(connection, request)
      if request.url.start_with? "/livereload.js"
        return connection.respond :ok, {"Content_Type" => 'application/ecmascript'}, File.read(File.join(File.dirname(__FILE__), "../../vendor", "livereload.js"))
      end

      path = File.join(Linner.environment.public_folder, request.url[1..-1])
      if File.exist?(path)
        content_type = case File.extname(path)
        when '.css' then 'text/css'
        when '.js' then 'application/ecmascript'
        when '.gif' then 'image/gif'
        when '.jpeg', '.jpg' then 'image/jpeg'
        when '.png' then 'image/png'
        else; 'text/plain'
        end
        return connection.respond :ok, {"Content_Type" => content_type, "Content_Length" => File.size(path)}, File.read(path)
      end

      connection.respond :not_found, "Not found"
    end

    def route_websocket(socket)
      socket << JSON.generate({
        :command    => 'hello',
        :protocols  => ['http://livereload.com/protocols/official-7'],
        :serverName => 'reel-livereload'
      })
      if socket.url == "/livereload"
        @clients << Client.new(socket)
      else
        socket.close
      end
    end

    def reload_browser(paths = [])
      paths.each do |path|
        @clients.each {|c| c.notify_asset_change path }
      end
    end

    class Client
      include Celluloid

      def initialize(socket)
        @socket = socket
      end

      def notify_asset_change(path)
        data = {
          :path     => path,
          :command  => 'reload',
          :liveCSS  => true
        }
        @socket << JSON.generate(data)
      rescue
      end
    end
  end
end
