require "terminal-notifier"

module Linner
  class Notifier

    def self.notify
      time = Time.now
      yield
      message = "🍜 : Done in #{'%.3f' % (Time.now - time)}s"
      if Linner.config.notifications && TerminalNotifier.available?
        TerminalNotifier.notify message, :title => 'Linner'
      else
        puts message
      end
    end
  end
end
