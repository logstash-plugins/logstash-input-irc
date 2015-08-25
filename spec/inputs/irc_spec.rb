# encoding: utf-8
require_relative "../spec_helper"
require "logstash/plugin"
require "logstash/event"

describe LogStash::Inputs::Irc do

  let(:properties) { {:name => "foo" } }
  let(:event)      { LogStash::Event.new(properties) }

  let(:host)       { "freenode.org" }
  let(:channels)   { ["foo", "bar"] }

  it "should register without errors" do
    plugin = LogStash::Plugin.lookup("input", "irc").new({ "host" => host, "channels" => channels })
    expect { plugin.register }.to_not raise_error
  end
end
