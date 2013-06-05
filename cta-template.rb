#List of modifications to a regular rails app:

#  sets up gemfile
gem 'pg'
gem 'haml-rails', '~> 0.4'
gem 'annotate', '~> 2.5.0'

gem_group :test do
  gem 'rspec', '~> 2.13.0'
  gem 'rspec-rails', '~> 2.13.0'
  gem 'rspec-spies', '~> 2.1.4'
  gem 'guard-rspec', '~> 3.0.1'
  gem 'guard-spork', '~> 1.5.0'
  gem 'capybara', '~> 2.1.0'
  gem 'spork', '~> 1.0.0.rc3'
  gem 'factory_girl_rails', '~> 4.2.1'
  gem 'shoulda-matchers', '~> 2.1.0'
  gem 'database_cleaner', '~> 1.0.1'
  gem 'rb-fsevent', '~> 0.9.2'
  gem 'growl', '~> 1.0.3'
end

gem_group :development do
  gem 'better_errors' ,'~> 0.9.0'
end

#  rspec instead test/unit
run 'rails generate rspec:install'
run 'rm -rf test/'

#  html2haml on application.html.erb
run 'gem install html2haml' unless `gem list`.lines.grep(/^html2haml \(.*\)/)
run 'html2haml app/views/layouts/application.html.erb app/views/layouts/application.html.haml'
run 'rm app/views/layouts/application.html.erb'

#  guard and spork
run 'guard init'

#  database.yml and database.yml.example
run 'rm config/database.yml'
file 'config/database.yml', <<-CODE
development:
  adapter: postgresql
  encoding: unicode
  database: #{@app_name}_dev
  pool: 5
  username: 
  password:

test:
  adapter: postgresql
  encoding: unicode
  database: #{@app_name}_test
  pool: 5
  username: 
  password:

production:
  adapter: postgresql
  encoding: unicode
  database: #{@app_name}
  pool: 5
  username: 
  password:
CODE
run 'cp config/database.yml config/database.yml.example'

#  .gitignore
run 'rm .gitignore'
file '.gitignore', <<-CODE
# Ignore bundler config
/.bundle

# Ignore the default SQLite database.
/db/*.sqlite3
config/database.yml

# Ignore all logfiles and tempfiles.
/log/*.log
/tmp
*.gem
*.rbc
.bundle
.config
coverage
InstalledFiles
lib/bundler/man
pkg
rdoc
spec/reports
tmp
*.DS_Store

# YARD artifacts
.yardoc
_yardoc
doc/
CODE

#  config/application.rb
run 'rm config/application.rb'
file 'config/application.rb', <<-CODE
require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module #{@app_name.titleize.gsub(' ','')}
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(\#{config.root}/lib)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.generators do |g|
      g.test_framework :rspec,
        fixtures:           true,
        view_specs:         true,
        helper_specs:       false,
        routing_specs:      false,
        controller_specs:   true,
        request_specs:      true
      g.fixture_replacement :factory_girl, :dir => "spec/factories"
    end
  end
end
CODE


#  spec\_helper.rb
run 'rm -rf spec/spec_helper.rb'
file 'spec/spec_helper.rb', <<-CODE
require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.


  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'
  require 'capybara/rails'
  require 'capybara/rspec'
  require 'database_cleaner'
  require 'rspec-spies'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

  RSpec.configure do |config|
    # ## Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = "\#{::Rails.root}/spec/fixtures"
    config.filter_run focus: true
    config.run_all_when_everything_filtered = true

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = false    

    config.before(:suite) { DatabaseCleaner.strategy = :truncation } 

    config.before(:each) { DatabaseCleaner.start }

    config.after(:each) { DatabaseCleaner.clean }

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

    # Run specs in random order to surface order dependencies. If you find an
    # order dependency and want to debug it, you can fix the order by providing
    # the seed, which is printed after each run.
    #     --seed 1234
    config.order = "random"
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.
  FactoryGirl.reload
end
CODE

