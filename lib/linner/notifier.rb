require "terminal-notifier"

module Linner
  class Notifier

    def self.notify
      time = Time.now
      yield
      puts message = "🍜 : Done in #{'%.3f' % (Time.now - time)}s"
    end

    def self.error(message)
      puts message = "👻 : #{message}"
      if Linner.config.notifications && TerminalNotifier.available?
        TerminalNotifier.notify message, :title => 'Linner'
      end
    end
  end
end
