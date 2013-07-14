require "terminal-notifier"

module Linner
  class Notifier

    def self.info
      time = Time.now
      yield
      puts "🍜 : Done in #{'%.3f' % (Time.now - time)}s."
    end

    def self.error(message)
      puts message = "👻 : #{message}!"
      if Linner.environment.notifications && TerminalNotifier.available?
        TerminalNotifier.info message, :title => 'Linner'
      end
    end

    def self.exit
      puts "\r🍵 : Let's take a break!"
    end
  end
end
