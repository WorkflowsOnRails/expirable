module Expirable
  extend ActiveSupport::Concern

  @klasses = []

  def self.register(klass)
    @klasses << klass
  end

  included do
    Expirable.register(self)
  end

  private

  def self.send_expired_event(object)
    Rails.logger.info "Sending deadline expired event to #{object}"
    begin
      object.deadline_expired
    rescue Expirable => e
      Rails.logger.error <<-eos.strip_heredoc
        Deadline expiration failed with #{e.message}
        #{e.backtrace.join("\n")}
      eos
    end
  end

  def self.send_expired_events
    @klasses.each do |klass|
      klass.newly_expired.each do |object|
        self.delay.send_expired_event(object)
      end
    end

    nil
  end
end
