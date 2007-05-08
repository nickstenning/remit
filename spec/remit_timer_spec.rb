require 'lib/remit'

describe "A new timer" do
  before(:each) do
    @t = Remit::Timer.new("example")
  end
  it "should have a name by which it can be identified" do
    @t.name.should == "example"
  end
  it "should not be ticking" do
    @t.should_not be_ticking
  end
  it "should have no start or stop times recorded" do
    @t.history.should be_empty
  end
end

describe "A started timer" do
  before(:each) do
    @t = Remit::Timer.new("example")
    @t.start
  end
  it "should be ticking" do
    @t.should be_ticking
  end
  it "should be counting in the right direction" do
    a = @t.time
    sleep 0.05
    b = @t.time
    (b - a).should be_close(0.05, 0.01)
  end
  it "should raise a RuntimeError if told to start again" do
    proc { @t.start }.should raise_error(RuntimeError)
  end
end

describe "A stopped timer" do
  before(:each) do
    @t = Remit::Timer.new("example")
    @t.start
    @t.stop
  end
  it "should not be ticking" do
    @t.should_not be_ticking
  end
  it "should raise a RuntimeError if told to stop again" do
    proc { @t.stop }.should raise_error(RuntimeError)
  end
end

describe "A timer started 'n' minutes ago" do
  before(:each) do
    @t = Remit::Timer.new("example")
    @t.start "5 minutes ago"
  end
  it "should be ticking" do
    @t.should be_ticking
  end
  it "should have been running for 'n' minutes" do
    @t.time.should be_close(300.0, 0.1)
  end
end

describe "A timer started 'n' minutes ago and now stopped" do
  before(:each) do
    @t = Remit::Timer.new("example")
    @t.start "5 minutes ago"
    @t.stop
  end
  it "should not be ticking" do
    @t.should_not be_ticking
  end
  it "should have been running for 'n' minutes" do
    @t.time.should be_close(300.0, 0.1)
  end
end

describe "A timer started 'n' minutes ago and stopped in 'n' minutes" do
  before(:each) do
    @t = Remit::Timer.new("example")
    @t.start "5 minutes ago"
    @t.stop "in 5 minutes"
  end
  it "should be ticking" do
    @t.should be_ticking
  end
  it "should have been running for 'n' minutes" do
    @t.time.should be_close(300.0, 0.1)
  end
end

describe "A timer started in 'n' minutes" do
  before(:each) do
    @t = Remit::Timer.new("example")
    @t.start "in 5 minutes"
  end
  it "should not be ticking" do
    @t.should_not be_ticking
  end
  it "should have counted no time" do
    @t.time.should == 0
  end
end

describe "A timer started in 'n' minutes and stopped 'n' minutes ago" do
  before(:each) do
    @t = Remit::Timer.new("example")
    @t.start "in 5 minutes"
    @t.stop "5 minutes ago"
  end
  it "should not be ticking" do
    @t.should_not be_ticking
  end
  it "should have counted no time" do
    @t.time.should == 0
  end
end
