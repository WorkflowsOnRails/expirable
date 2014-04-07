# Basic unit test for the library functionality in Expirable.
#
# @author Brendan MacDonell

require 'spec_helper'

module Expirable
  # Fake the presence of Delayed::Job by executing each event immediately.
  def self.delay
    self
  end

  # Disable the logger, since we don't need it.
  LOGGER.level = ActiveSupport::Logger::Severity::UNKNOWN
end

class Fake
  include Expirable
end

describe Expirable do
  before :each do
    Expirable
  end

  it 'does nothing when there are no newly expired objects' do
    allow(Fake).to receive(:newly_expired) { [] }

    Expirable.send_expired_events
  end

  it 'calls send_expired_event on each newly expired object' do
    fake = Fake.new

    allow(Fake).to receive(:newly_expired) { [fake] }
    expect(fake).to receive(:deadline_expired)

    Expirable.send_expired_events
  end

  it 'handles multiple newly-expired objects' do
    fakes = 3.times.map { Fake.new }

    allow(Fake).to receive(:newly_expired) { fakes }
    fakes.each { |fake| expect(fake).to receive(:deadline_expired) }

    Expirable.send_expired_events
  end

  it 'it does not halt due to exceptions' do
    failing_fake = Fake.new
    fake = Fake.new

    allow(Expirable).to receive(:delay) { Expirable }
    allow(Fake).to receive(:newly_expired) { [failing_fake, fake] }
    expect(failing_fake).to receive(:deadline_expired).and_raise(RuntimeError.new)
    expect(fake).to receive(:deadline_expired)

    Expirable.send_expired_events
  end
end
