require 'clockwork'
require './config/boot'
require './config/environment'

# Ensure all of the models are loaded. Expirable models are automatically
#  registered when their class definitions are evaluated, so we need to
#  load all of them when clockwork starts up.
Rails.application.eager_load!

module Clockwork
  every 1.hour, 'Expirable.send_expired_events', at: '**:01' do
    Expirable.send_expired_events
  end
end
