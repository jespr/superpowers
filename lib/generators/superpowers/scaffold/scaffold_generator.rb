require 'rails/generators'
require 'rails/generators/named_base'
require 'rails/generators/resource_helpers'
# require 'rails/generators/active_record/migration'

module Superpowers
  module Generators
    class ScaffoldGenerator < Rails::Generators::NamedBase
      include Rails::Generators::ResourceHelpers

      source_root File.expand_path('../templates', __FILE__)

      class_option :orm, banner: "NAME", type: :string, required: true, desc: "ORM to generate the controller for"
      class_option :scope, banner: "SCOPE", type: :string, desc: "Instance/model to scope for. Example: current_user or Project"
      class_option :nested_route, type: :boolean, default: false

      argument :attributes, type: :array, default: [], banner: "field:type field:type"

      hook_for :helper, in: :rails

      hook_for :assets, in: :rails

      hook_for :stylesheet_engine

      remove_hook_for :resource_route
      # override
      def add_resource_route
        return if options[:actions].present?

        route_config = "resources :#{file_name.pluralize}\n"

        if @options[:nested_route]
          route_config = "resources :#{plural_nested_parent_name} do\n" \
                         "  resources :#{file_name.pluralize}\n" \
                         "end\n"
        end

        route route_config

        gsub_file 'config/routes.rb', / *resources :#{plural_nested_parent_name}\n/, ''
      end

      def initialize(args, *options) #:nodoc:
        super
      end

      def create_controller
        template "controller.rb", File.join('app/controllers', "#{controller_file_name}_controller.rb"), behavior: self.behavior
      end

      def scaffold_views
        invoke "erb:scaffold", [singular_name, migration_attributes], behavior: self.behavior
      end

      def generate_model_and_insert_association
        case self.behavior
        when :invoke
          invoke :model, [singular_name, migration_attributes, scoped_by_reference].flatten, behavior: :invoke
          inject_into_file scoped_by_file_path, "\n  has_many :#{plural_name}", after: "ApplicationRecord"
        when :revoke
          # gsub_file doesn't work for some reason, so this is a quick temp solution
          content = File.read(scoped_by_file_path).gsub(/\s*has_many :#{plural_name}/, '')
          File.open(scoped_by_file_path, 'wb') { |file| file.write(content) }

          invoke :model, [singular_name], behavior: :revoke
        end
      end

      private

      def migration_attributes
        attributes.map { |a| "#{a.name}:#{a.type}" if a.type }
      end

      def scoped_by_reference
        if scoped_arg.start_with?('current_')
          klass = scoped_arg.gsub('current_', '')
        end
        [klass, ':', 'references'].join('')
      end

      def nested_parent_name
        scoped_arg.gsub('current_', '').singularize
      end

      def plural_nested_parent_name
        nested_parent_name.pluralize
      end

      def scoped_by_file_path
        file_name = scoped_arg.gsub('current_', '')
        "app/models/#{file_name}.rb"
      end

      def scoped_arg
        if @options["scope"].start_with?('current_')
          @options["scope"]
        end
      end

      def scoped_class
        scoped_arg.classify
      end

      def resource_arg
        name.split('/').last.downcase.singularize
      end

      def resource_plural
        resource_arg.pluralize
      end

      def nested_routes?
        @options[:nested_route]
      end

      def scoped_resource
        if nested_routes?
          ["@#{nested_parent_name}", resource_plural].join('.')
        else
          [scoped_arg, resource_plural].join('.')
        end
      end
    end
  end
end
