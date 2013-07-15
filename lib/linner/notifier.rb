require "terminal-notifier"

module Linner
  class Notifier
    class << self
      def info
        time = Time.now
        yield
        puts "🍜 : Done in #{'%.3f' % (Time.now - time)}s."
      end

      def error(message)
        puts message = "👻 : #{message}!"
        if Linner.environment.notifications && TerminalNotifier.available?
          TerminalNotifier.notify message, :title => 'Linner'
        end
      end

      def exit
        puts "\r🍵 : Let's take a break!"
      end
    end
  end
end
