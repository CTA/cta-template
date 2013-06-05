CTA Rails Application Template
============

Simple template for customizing the rails environment

Here's how you use this template when creating a new rails app:

  `rails new myapp -m cta-template.rb`

List of modifications to a regular rails app:
  * Changes the database.yml to postgres defaults and creates a database.yml.example.
  * Adds a .gitignore with more common files.
  * Adds test generator lines to config/application.rb
  * Adds custom spec\_helper.rb with Spork options
  * Installs Rspec instead Test::Unit.
  * Sets up guard and spork to run off the bat.
  * Converts application.html.erb to application.html.haml
  * Sets up gemfile with some common gems
