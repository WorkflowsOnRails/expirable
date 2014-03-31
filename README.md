Expirable
=========

Expirable is a simple Rails mixin to handle deadlines in workflows.
It builds on [Delayed::Job](https://github.com/collectiveidea/delayed_job)
and [Clockwork](https://github.com/tomykaira/clockwork) to provide a painless approach
to handling time-based events.


Installation
------------

To install the Expirable and its dependencies, add `expirable` and an
appropriate Delayed::Jobs backend to your Gemfile:
```rb
gem 'delayed_job_active_record'
gem 'expirable'
```

Next, set up Delayed::Job if you are not already using it in your project:
```bash
rails generate delayed_job:active_record
rake db:migrate
```

Finally, set up Expirable itself by running `rails g expirable:setup`.
This will create a Clockwork configuration file called _lib/clock.rb_.
By default, it is configured to check deadlines at one minute past every hour.
See the [Clockwork manual](https://github.com/tomykaira/clockwork#clockwork---a-clock-process-to-replace-cron--)
for more information if you need to change this configuration.


Running Expirable
-----------------

To run Expirable, you will need to run a Clockwork worker and a Delayed::Job worker.
You can run the Clockwork worker by executing `bundle exec clockwork lib/clock.rb`
from the root of the Rails project, and Delayed::Job worker with `./bin/delayed_job run`.

You can also use [Foreman](http://blog.daviddollar.org/2011/05/06/introducing-foreman.html)
to manage these processes. For example, if you run your Rails application on Unicorn, then
you can create a `Procfile` with the following content and run your application with `foreman start`:
```conf
cron: bundle exec clockwork lib/clock.rb
web: bundle exec unicorn_rails
worker: ./bin/delayed_job run
```


Handling Deadlines
------------------

To be expirable, a class must do the following three things:

1. include `Expirable`;
2. define a `deadline_expired` instance method that will be invoked when the model's deadline expires; and
3. define a class method named `newly_expired` that returns a collection of model instances that have expired, but haven't yet received a `deadline_expired` message.

As an example, the following model uses [AASM](https://github.com/aasm/aasm) and Expirable to transition tasks to a failed state when their deadline is passed:
```rb
class ExampleTask < ActiveRecord::Base
  include AASM
  include Expirable
  
  scope :newly_expired,
        -> { in_progress.where('deadline < ?', DateTime.now) }

  aasm do
    # ... state and event definitions skipped ...

    event :deadline_expired do
      transitions from: :in_progress, to: :missed
    end
  end
end
```
