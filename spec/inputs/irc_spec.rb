# encoding: utf-8
require_relative "../spec_helper"
require "logstash/plugin"
require "logstash/event"
require "cinch"

describe LogStash::Inputs::Irc do

  let(:properties) { {:name => "foo" } }
  let(:event)      { LogStash::Event.new(properties) }

  let(:host)       { "irc.freenode.org" }
  let(:channels)   { ["foo", "bar"] }

  it "should register without errors" do
    plugin = LogStash::Plugin.lookup("input", "irc").new({ "host" => host, "channels" => channels })
    expect { plugin.register }.to_not raise_error
  end

  context "when stopping the plugin" do
    it_behaves_like "an interruptible input plugin" do
      let(:host)       { "irc.freenode.org" }
      let(:channels)   { ["foo", "bar"] }
      let(:config) { {  "host" => host, "channels" => channels, "get_stats" => true } }
    end
  end

  describe "receive" do

    let(:config) { { "host" => host, "channels" => channels } }
    subject      { LogStash::Inputs::Irc.new(config) }

    let(:msg)    { double("message") }
    let(:user)   { double("user") }

    let(:user_data) { { host: "host", nick: "nick"} }

    before(:each) do
      allow(msg).to receive(:message).and_return("message")
      allow(msg).to receive(:command).and_return("command")
      allow(user).to receive(:data).and_return(user_data)
      allow(user).to receive(:nick).and_return(user_data[:nick])
      allow(msg).to receive(:user).and_return(user)
      allow(msg).to receive(:prefix).and_return("prefix")
      allow(msg).to receive(:channel).and_return("channel")

      subject.inject_bot(bot).register
    end

    let(:bot)     { Cinch::Bot.new }
    let(:channel) { bot.handlers.find(:channel).first }
    let(:nevents) { 1 }

    let(:events) do
      plugin_input(subject) do |queue|
        nevents.times do
          channel.call(msg, [], [])
        end
        result = nevents.times.inject([]) do |acc|
          acc << queue.pop
        end
        result
      end
    end

    let(:event) { events.first }

    it "receive events from a channel" do
      expect(event.get("channel")).to eq("channel")
    end

    it "receive events with a command" do
      expect(event.get("command")).to eq("command")
    end

    it "receive events with nick information" do
      expect(event.get("nick")).to eq("nick")
    end

    it "receive events with host information" do
      expect(event.get("host")).to eq("host")
    end

    context "when host is unavailable" do

      let(:user_data) { super().merge(host: nil)}

      it "handles unknown host well" do
        expect(event.get("host")).to be_nil
      end
    end
  end
end
