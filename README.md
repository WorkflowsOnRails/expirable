Expirable
=========

Expirable is a simple Rails mixin to handle deadlines in workflows.
It builds on [Delayed::Job](https://github.com/collectiveidea/delayed_job)
and [Clockwork](https://github.com/tomykaira/clockwork) to ???


Installation
------------

To install the Expirable and its dependencies, add `expirable` and an
appropriate delayed_jobs backend to your Gemfile:

```rb
gem 'delayed_job_active_record'
gem 'expirable', git: 'https://github.com/WorkflowsOnRails/expirable.git', branch: 'master'
```

Next, set up Delayed::Job if you are not already using it in your project:

```bash
rails generate delayed_job:active_record
rake db:migrate
```

Finally, generate a configuration file for clockwork by running
`rails g expirable:setup`. It will create a file called _lib/clock.rb` with
the following contents:

```rb
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
```

This specifies that deadlines will checked every hour at one minute past.
See the [Clockwork manual](https://github.com/tomykaira/clockwork#clockwork---a-clock-process-to-replace-cron--) if you need to customize this behavior.


Handling Deadlines
------------------
