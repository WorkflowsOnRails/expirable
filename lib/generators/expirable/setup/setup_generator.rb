module Expirable
  module Generators
    class SetupGenerator < Rails::Generators::Base
      desc "Creates a basic clock.rb file to perform expiration hourly"

      source_root File.expand_path("../templates", __FILE__)

      def create_clock_config
        copy_file "clock.rb", "lib/clock.rb"
      end
    end
  end
end
