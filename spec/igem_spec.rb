require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require "stringio"

describe "IGem" do

  before do
    $stdout = StringIO.new
  end

  def output
    $stdout.string
  end

  after do
    $stdout = STDOUT
  end

  it "can execute a ruby file" do
    igem "spec/helpers/example.rb hello", :fork => false
    output.should == "hello"
  end

  it "can fork" do
    igem "spec/helpers/example.rb hello", :fork => true
    output.should == ""
  end

  it "will fork by default" do
    igem "spec/helpers/example.rb hello"
    output.should == ""
  end
end
