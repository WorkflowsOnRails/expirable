# Rails model mixin that supports deadlines in workflows.
#
# It requires clients to do the following:
#  1. Include Expirable
#  2. define a `deadline_expired` instance method that will be invoked when the
#     model's deadline expires
#  3. define a class method named `newly_expired` that returns a collection of model
#     instances that have expired, but haven't yet received a `deadline_expired`
#     message.
#
# The mixin relies on an external service to periodically call
# `Expirable.send_expired_events`, which polls for models which have expired but
# have not yet received a `deadline_expired` message.
#
# @author Brendan MacDonell <brendan@macdonell.net>

require 'active_support'
require 'active_support/core_ext'

module Expirable
  extend ActiveSupport::Concern

  LOGGER = defined?(Rails) ? Rails.logger : ActiveSupport::Logger.new(STDERR)

  # @klasses is a collection holding all classes that have included Expirable.
  @klasses = []

  def self.register(klass)
    @klasses << klass
  end

  included do
    Expirable.register(self)
  end

  def self.send_expired_event(object)
    LOGGER.info "Sending deadline expired event to #{object}"

    begin
      object.deadline_expired
    rescue Exception => e
      LOGGER.error <<-eos.strip_heredoc
        Deadline expiration failed with #{e.message}
        #{e.backtrace.join("\n")}
      eos
    end
  end

  # Called periodically to send `deadline_expired` messages. It doesn't actually
  # send the messages sequentially, but enqueues a call to `send_expired_event` to
  # execute the message send asynchronously.
  #
  # Note that this method has no notion of priority, and may enqueue calls on objects
  # that already have method calls enqueued. It is up to the client to make sure that
  # there are enough workers so that the processing rate of the queue exceeds the
  # arrival rate.
  def self.send_expired_events
    @klasses.each do |klass|
      klass.newly_expired.each do |object|
        self.delay.send_expired_event(object)
      end
    end

    nil
  end
end
