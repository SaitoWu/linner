require "terminal-notifier"

module Linner
  class Notifier

    def self.notify
      time = Time.now
      yield
      if TerminalNotifier.available?
        TerminalNotifier.notify "🍜 : Done in #{'%.3f' % (Time.now - time)}s", :title => 'Linner'
      end
    end
  end
end
