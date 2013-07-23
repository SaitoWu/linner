require "reel"
require "json"

module Linner
  class Reactor
    class Server < Reel::Server

      def initialize(host = "127.0.0.1", port = 35729)
        super(host, port, &method(:on_connection))
      end

      def on_connection(connection)
        while request = connection.request
          case request
          when Reel::Request
            route_request connection, request
          when Reel::WebSocket
            route_websocket request
          end
        end
      end

      def route_request(connection, request)
        if request.url.start_with? "/livereload.js"
          return connection.respond :ok, File.read(File.join(File.dirname(__FILE__), "../../vendor", "livereload.js"))
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
        socket.write JSON.generate({
          :command    => 'hello',
          :protocols  => ['http://livereload.com/protocols/official-7'],
          :serverName => 'reel-livereload'
        })
        # sleep 2
        # socket.write JSON.generate({
        #   :command  => 'reload',
        #   :path     => "/scripts/app.js",
        #   :liveCSS  => true
        # })
        # socket.close
      end
    end

    # class Client
    #   def initialize(socket)
    #     @socket = socket
    #     async.run
    #   end

    #   def reload_browser(paths)
    #     publish "", "{a: 1}"
    #   end
    # end
  end
end
