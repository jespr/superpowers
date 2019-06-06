$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "superpowers"

require "minitest/autorun"

require 'rails'
require 'rails/generators'

class TestApp < Rails::Application
  config.root = File.dirname(__FILE__)
end
Rails.application = TestApp

module Rails
  def self.root
    @root ||= File.expand_path(File.join(File.dirname(__FILE__), '..', 'tmp', 'rails'))
  end
end
Rails.application.config.root = Rails.root

Rails::Generators.configure! Rails.application.config.generators

def copy_routes
  routes = File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', 'routes.rb'))
  destination = File.join(Rails.root, "config")
  FileUtils.mkdir_p(destination)
  FileUtils.cp File.expand_path(routes), destination
end

def copy_models
  model = File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', 'user.rb'))
  destination = File.join(Rails.root, "app", "models")
  FileUtils.mkdir_p(destination)
  FileUtils.cp File.expand_path(model), destination
end

def generator_list
  {
    rails: ['scaffold', 'controller', 'migration'],
    superpowers: ['scaffold']
  }
end

def path_prefix(name)
  case name
  when :rails
    'rails/generators'
  else
    'generators'
  end
end

def require_generators(generator_list)
  generator_list.each do |name, generators|
    generators.each do |generator_name|
      if name.to_s == 'rails' && generator_name.to_s == 'mailer'
        require File.join(path_prefix(name), generator_name.to_s, "#{generator_name}_generator")
      else
        require File.join(path_prefix(name), name.to_s, generator_name.to_s, "#{generator_name}_generator")
      end
    end
  end
end
alias :require_generator :require_generators
