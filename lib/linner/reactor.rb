require "eventmachine"
require "em-websocket"
require "http/parser"

module Linner
  # Steal from guard livereload
  # https://github.com/guard/guard-livereload/blob/master/lib/guard/livereload/reactor.rb
  class Reactor
    OPTIONS = {
      :host => '0.0.0.0',
      :port => '35729',
      :apply_css_live => true,
      :override_url => false,
      :grace_period => 0
    }

    attr_reader :web_sockets, :thread, :options

    def initialize
      @web_sockets = []
      @options     = OPTIONS
      @thread      = start_threaded_reactor(OPTIONS)
    end

    def stop
      thread.kill
    end

    def reload_browser(paths = [])
      paths.each do |path|
        data = {
          :command  => 'reload',
          :path     => "/#{path}",
          :liveCSS  => @options[:apply_css_live]
        }
        web_sockets.each { |ws| ws.send(MultiJson.encode(data)) }
      end
    end

  private

    def start_threaded_reactor(options)
      Thread.new do
        EventMachine.epoll
        EventMachine.run do
          EventMachine.start_server(options[:host], options[:port], Connection, {}) do |ws|
            ws.onopen do
              begin
                ws.send MultiJson.encode({
                  :command    => 'hello',
                  :protocols  => ['http://livereload.com/protocols/official-7'],
                  :serverName => 'guard-livereload'
                })
                @web_sockets << ws
              rescue
                Notifier.error $!
              end
            end

            ws.onclose do
              @web_sockets.delete(ws)
            end
          end
        end
      end
    end



    class Connection < EventMachine::WebSocket::Connection
      def dispatch data
        parser = Http::Parser.new
        parser << data
        if parser.http_method != 'GET' || parser.upgrade?
          super #pass the request to websocket
        elsif parser.request_path == '/livereload.js'
          serve_file File.join(File.dirname(__FILE__), "../../vendor", "livereload.js")
        elsif File.exist?(parser.request_path[1..-1])
          serve_file parser.request_path[1..-1] # Strip leading slash
        else
          send_data "HTTP/1.1 404 Not Found\r\nContent-Type: text/plain\r\nContent-Length: 13\r\n\r\n404 Not Found"
          close_connection_after_writing
        end
      end

      def serve_file path
        content_type = case File.extname(path)
        when '.css' then 'text/css'
        when '.js' then 'application/ecmascript'
        when '.gif' then 'image/gif'
        when '.jpeg', '.jpg' then 'image/jpeg'
        when '.png' then 'image/png'
        else; 'text/plain'
        end
        send_data "HTTP/1.1 200 OK\r\nContent-Type: #{content_type}\r\nContent-Length: #{File.size path}\r\n\r\n"
        stream_file_data(path).callback { close_connection_after_writing }
      end
    end

  end
end
