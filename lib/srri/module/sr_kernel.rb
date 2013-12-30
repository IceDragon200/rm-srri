#
# rm-srri/lib/srri/module/sr_kernel.rb
#
module SRRI
  module SRKernel

    def rgss_main
      SRRI.mk_starruby
      SRRI::Graphics.init
      SRRI::Audio.init
      SRRI::Input.init

      begin
        yield
      rescue SRRI::RGSSReset
        SRRI.try_log { |logger| logger.puts("Reset Signal received") }
        Graphics.__reset__
        retry
      rescue SRRI::Interrupts::SRRIBreak
        SRRI.try_log { |logger| logger.puts("Break Signal received") }
      end
    end

    def rgss_stop
      loop { Graphics.update }
    end

  end
end