require 'rubygems'
require 'chronic'

module Remit
  
  VERSION = "0.0.1"

  TimeSpan = Struct.new("TimeSpan", :start, :stop, :description)

  class Timer
    attr_reader :name, :history
    def initialize( name )
      @name = name
      @history = []
    end
    def start( time="now" )
      raise "Already started!" if latest.start and latest.stop.nil? 
      @history << TimeSpan.new(parse(time), nil)
      latest
    end
    def stop( time="now" )
      raise "Already stopped!" unless latest.stop.nil?
      latest.stop = parse(time)
      latest
    end
    def latest
      @history.last || TimeSpan.new
    end
    def ticking?
      if latest.stop.nil? or latest.stop > Time.now # no stop time || not yet stopped
        !latest.start.nil? and latest.start <= Time.now # not a new timer && ticking
      else
        false
      end
    end
    def time
      @history.inject(0.0) do |sum, timespan|
        next sum if timespan.start > Time.now
        diff = if timespan.stop.nil? or timespan.stop > Time.now
                 Time.now
               else
                 timespan.stop
               end - timespan.start
        next sum unless diff > 0
        sum += diff
      end
    end
    def parse( expr )
      time = Chronic.parse(expr)
      raise "Unparseable time expression! (#{expr})" unless time.kind_of? Time
      return time
    end
    def ==( x )
      [@name, @history] == [x.name, x.history]
    end
  end
end
