#
# rm-srri/lib/patches/StarRuby_Game.rb
#
__END__
class StarRuby::Game

  attr_accessor :event_thread, :event_thread_active
  attr_accessor :mutex

  class EventThread < Thread

    def self.new(game)
      super() do
        kill_game = ->(reason) do
          game.dispose unless game.disposed?
          game.event_thread = nil
        end
        loop do
          next unless game.event_thread_active
          if game.mutex.synchronize
            begin
              (kill_game.(:closing); break) if game.window_closing?
              game.update_events
              game.mutex.unlock
              sleep 1.0 / game.fps
            rescue Exception => ex
              $stdout << "StarRuby::Game::EventThread failed with #{ex.message}\n"
              kill_game.(:exception); break
            end
          end
        end
        exit
      end
    end
  end

  def self.srri_new(*args, &block)
    game = new(*args, &block)
    game.event_thread = EventThread.new(game)
    game.event_thread.abort_on_exception = false
    game.event_thread_active = true
    game.mutex = Mutex.new
    return game
  end

end

