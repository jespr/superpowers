require 'test_helper'
require_generator :superpowers   => ['scaffold']
require_generator :rails   => ['scaffold']

class ScaffoldGeneratorTest < Rails::Generators::TestCase
  destination File.join(Rails.root)
  tests Superpowers::Generators::ScaffoldGenerator

  setup :prepare_destination
  setup :copy_routes
  setup :copy_models

  test 'nests the route if nested_route is set' do
    run_generator %w(project title description:text --scope=current_user --nested_route)

    assert_file "config/routes.rb" do |content|
      assert_match(/resources :users do\n    resources :projects\n  end/, content)
    end

    assert_file "app/controllers/projects_controller.rb" do |content|
      assert_match(/before_action :set_project, only: \[:show, :edit, :update, :destroy\]/, content)
      assert_match(/before_action :set_user, only: \[:show, :edit, :update, :destroy\]/, content)

      assert_instance_method :index, content do |m|
        assert_match(/@pagy, @projects = pagy\(@user.projects.all\)/, m)
      end

      assert_instance_method :show, content

      assert_instance_method :new, content do |m|
        assert_match(/@project = @user\.projects\.new/, m)
      end

      assert_instance_method :edit, content

      assert_instance_method :create, content do |m|
        assert_match(/@project = @user\.projects\.new\(project_params\)/, m)
        assert_match(/@project\.save/, m)
      end

      assert_instance_method :update, content do |m|
        assert_match(/@project\.update\(project_params\)/, m)
      end

      assert_instance_method :destroy, content do |m|
        assert_match(/@project\.destroy/, m)
      end

      assert_instance_method :set_project, content do |m|
        assert_match(/@project = @user\.projects\.find\(params\[:id\]\)/, m)
      end

      assert_match(/def project_params/, content)
      assert_match(/params\.require\(:project\)\.permit\(:title, :description\)/, content)
    end
  end

  test 'everything is created correctly scoped to current_user' do
    run_generator %w(project title description:text --scope=current_user)

    assert_file "app/controllers/projects_controller.rb" do |content|
      assert_match(/class ProjectsController < ApplicationController/, content)

      assert_instance_method :index, content do |m|
        assert_match(/@pagy, @projects = pagy\(current_user.projects.all\)/, m)
      end

      assert_instance_method :show, content

      assert_instance_method :new, content do |m|
        assert_match(/@project = current_user\.projects\.new/, m)
      end

      assert_instance_method :edit, content

      assert_instance_method :create, content do |m|
        assert_match(/@project = current_user\.projects\.new\(project_params\)/, m)
        assert_match(/@project\.save/, m)
      end

      assert_instance_method :update, content do |m|
        assert_match(/@project\.update\(project_params\)/, m)
      end

      assert_instance_method :destroy, content do |m|
        assert_match(/@project\.destroy/, m)
      end

      assert_instance_method :set_project, content do |m|
        assert_match(/@project = current_user\.projects\.find\(params\[:id\]\)/, m)
      end

      assert_match(/def project_params/, content)
      assert_match(/params\.require\(:project\)\.permit\(:title, :description\)/, content)
    end

    assert_file "app/assets/stylesheets/project.css"

    %w(index edit show _form new).each do |file_name|
      assert_file "app/views/projects/#{file_name}.html.erb"
    end

    assert_file "app/helpers/project_helper.rb"
  end
end
