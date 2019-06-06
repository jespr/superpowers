# Superpowers

Superpowers provides some generators to ease your Rails work:

- generate scoped/nested scaffolds easily

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'superpowers'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install superpowers

## Usage

### Create scoped scaffold

Many apps relies on users being logged in. This scaffold will make it easy for you to create a resource that is scoped to `current_user` but the route remains un-nested:

  `rails g superpowers:scaffold Project title --scope=current_user`

The above command will generate a scaffold named Project, which is scoped to `current_user`. It will create a `ProjectsController` where every ActiveRecord reference to `project`
is scoped like so `current_user.projects`.

### Create scoped scaffold with nested routes

  `rails g superpowers:scaffold Task name --scope=project --nested_route`

This command will create a scaffold scoped to `Project` and nested under the `resources :projects` route. It will create a `TasksController` where task is scoped to Project like so
`@project.tasks` - it also inserts a `before_action :set_project` which will look up the project: `@project = Project.find(params[:project_id]`.

## Planned Work

- Make it possible to create a scaffold where the resource is scoped to `--scope` and the model declared in `--scope` is scoped to let's say `current_user`.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jespr/superpowers. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Superpowers project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/jespr/superpowers/blob/master/CODE_OF_CONDUCT.md).
