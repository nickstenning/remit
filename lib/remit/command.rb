require 'lib/remit'
#require 'rubygems'
#require 'duration'

module Remit
  class Command
    attr_accessor :in, :out, :timers, :command, :expr
    def initialize( *args )
      @in, @out = STDIN, STDOUT
      @timers = []
      @commands = [:start, :stop, :rm, nil]
      set_args(*args)
    end
    def set_args( timer_name=nil, command=nil, *expr )
      @timer_name = timer_name
      @command = command.intern if command
      @expr = expr.any? ? expr.join(" ").strip : :now
    end
    def timer
      @timer ||= @timers.select { |t| t.name == @timer_name }.first
    end
    def run
      if timer or @command
        if @commands.include?(@command)
          @timers << Timer.new(@timer_name) unless timer
          send(@command) if @command
          out.puts timer_stats
        else
          out.puts unknown_command
        end
      else
        out.puts @timer_name ? unknown_timer : usage
      end
    end
    def start
      timer.start @expr
    end
    def stop
      timer.stop @expr
    end
    def rm
      out.print "Remove timer '#{timer.name}'? [yN] "
      @timers -= [timer] if self.in.gets.upcase =~ /^Y(ES)?/
    end
    def timer_stats
      "running: " + (timer.ticking? ? "yes" : "no") + "\n" +
      "   time: #{sprintf("%0.02f", timer.time / 3600)} hours" 
    end
    def unknown_timer
      "Unknown timer. Run `#{File.basename($0)} #{@timer_name} start` to create it."
    end
    def unknown_command
      "Unknown command '#{@command}'. Known commands are: " +
      @commands.compact.map { |x| x.to_s }.join(", ") + "."
    end
    def usage
      "Usage: #{File.basename($0)} <timer> <command> [time expression]\n" +
      "  e.g. `$ #{File.basename($0)} billing stop in 5 minutes`\n\n" +
      "Saved timers: #{@timers.map { |t| t.name }.join ", "}"
    end
    def ==( x )
      [timer, @command, @expression, @timers] == [x.timer, x.command, x.expression, x.timers]
    end
  end
end
