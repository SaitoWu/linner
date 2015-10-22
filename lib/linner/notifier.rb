require "terminal-notifier"

module Linner
  class Notifier
    class << self
      def profile
        time = Time.now
        yield
        puts "🍜 : Done in #{"%.3f" % (Time.now - time)}s."
      end

      def notify(message)
        if Linner.env.notification && TerminalNotifier.available?
          TerminalNotifier.notify message, :title => "Linner"
        end
        puts "👻 : #{message}!"
      end

      def error(message)
        self.notify(message)
        abort
      end

      def exit
        puts "\r🍵 : Let's take a break!"
      end
    end
  end
end
