# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require 'logstash/inputs/irc'

module IrcHelpers

  def self.input(plugin, &block)
    queue = Queue.new

    input_thread = Thread.new do
      plugin.run(queue)
    end
    result = block.call(queue)

    plugin.do_stop
    input_thread.join
    result
  end

end
