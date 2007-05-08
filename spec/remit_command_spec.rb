require 'lib/remit/command'

require 'stringio'

describe "A new command class" do
  before(:each) do
    @c = Remit::Command.new
  end
  it "should have an empty set of timers" do
    @c.timers.should be_empty
  end
  it "should be connected to stdin and stdout" do
    @c.in.should == STDIN
    @c.out.should == STDOUT
  end
  it "should allow its IO streams to be redirected" do
    iin = StringIO.new
    oout = StringIO.new
    @c.in = iin
    @c.out = oout
    @c.in.should == iin
    @c.out.should == oout
  end
  it "should return a usage message when called with no args" do
    @c.out = StringIO.new
    @c.run
    @c.out.string.should ==<<-EOM
Usage: #{File.basename($0)} <timer> <command> [time expression]
  e.g. `$ #{File.basename($0)} billing stop in 5 minutes`

Saved timers: 
    EOM
  end
  it "should return an 'unknown timer' message when called with an unknown timer and no command" do
    @c.out = StringIO.new
    @c.set_args("example")
    @c.run
    @c.out.string.should ==<<-EOM
Unknown timer. Run `#{File.basename($0)} example start` to create it.
    EOM
  end
  it "should return an 'unknown command' message when called with a known or unknown timer and an unknown command" do
    @c.out = StringIO.new
    @c.set_args("example", "splorp")
    @c.run
    @c.out.string.should ==<<-EOM
Unknown command 'splorp'. Known commands are: start, stop, rm.
    EOM
  end
end

describe "A command class with a timer" do
  before(:each) do
    @t = Remit::Timer.new("example_t")
    @c = Remit::Command.new
    @c.timers << @t
  end
  it "should have one timer" do
    @c.timers.length.should == 1
    @c.timers.first.should be_a_kind_of(Remit::Timer)
    @c.timers.first.should == @t
  end
  it "should accept timers on an array at #timers" do
    @u = Remit::Timer.new("example_u")
    @c.timers << @u
    @c.timers.length.should == 2
    @c.timers.last.should be_a_kind_of(Remit::Timer)
    @c.timers.last.should == @u
  end
  it "should accept ARGV-like parameters to select timer, command and time expression" do
    @c.set_args("example_t", "start", "5", "minutes", "ago")
    @c.timer.should == @t
    @c.command.should == :start
    @c.expr.should == "5 minutes ago"
  end
  it "should have a default expression of :now when not supplied" do
    @c.set_args("example_t", "start")
    @c.expr.should == :now
  end
end
