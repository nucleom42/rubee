![Tests](https://github.com/nucleom42/rubee/actions/workflows/test.yml/badge.svg)
![License](https://img.shields.io/github/license/nucleom42/rubee)
![Gem](https://img.shields.io/gem/dt/ruBee.svg)
![GitHub last commit](https://img.shields.io/github/last-commit/nucleom42/rubee.svg)
![Gem](https://img.shields.io/gem/v/ruBee.svg)
![GitHub Repo stars](https://img.shields.io/github/stars/nucleom42/rubee?style=social)


# <img src="lib/images/rubee.svg" alt="ruBee" height="40"> ... ruBee

ruBee is a fast and lightweight Ruby application server designed for minimalism and flexibility .

The main philosophy of ruBee is to focus on Ruby language explicit implementation of the MVC web application.

Want to get a quick API server up and runing? You can do it for real quick!
<br />
[![Video Title](https://img.youtube.com/vi/ko7H70s7qq0/0.jpg)](https://www.youtube.com/watch?v=ko7H70s7qq0)

All greaet features are yet to come!

## Features

- **Lightweight**: A minimal footprint that focuses on serving Ruby applications efficiently.
- **Contract driven**: Define your API contracts in a simple, declarative manner. And generate the files for you.
- **Fast**: Optimized for speed, providing a quick response to requests. Everything is relative, I know!
- **Rack**: Rack backed. All Rack api is available for integration.
- **Router**: Router driven - generates all required files from the routes.
- **Databases**: Sqlite3, Postgres, Mysql and many more supported by sequel gem.
- **Views**: Json, ERB and plain HTML
- **Bundlable** Charge your ruBee with any gem you need and update your project with bundle.
- **ORM** All models are natively ORM objects, however you can use it as a blueurpint for any datasources.
- **Authentificatable** Add JWT authentification easily to any controller action.
- **Hooks** Add logic before, after and around any action.
- **Test** Run all or selected tests witin minitest.
- **Asyncable** Add async adapter and pick any popular background job queue enginee

## Installation

1. Install ruBee
```bash
gem install ruBee
```

2. Create your first project
```bash
rubee project my_project
cd my_project
```

3. Install dependencies

***Prerequisites***<br />
**ruBee** is using **Sqlite** as a default database. However you can pick up any other database supported by sequel gem.
Aside that, make sure:
**Ruby** language (3+) is installed
**Bundler** is installed

```bash
bundle install
```

4. Run ruBee server. Default port is 7000
```bash
rubee start
```

5. Open your browser and go to http://localhost:7000

## Create API contract and generate files from the routes
1. Add the routes to the routes.rb
```bash
Rubee::Router.draw do |router|
  ...
  # draw the contract
  router.get "/apples", to: "apples#index",
    model: {
      name: "apple",
      attributes: [
        { name: 'id', type: :integer },
        { name: 'colour', type: :string },
        { name: 'weight', type: :integer }
      ]
    }
end
```
2. genrate the files
```bash
rubee generate get /apples
```
3. This will generate the following files
```bash
./app/controllers/apples_controller.rb # Controller with respective action
./app/models/apple.rb # Model that acts as ORM
./app/views/apples_index.erb # ERB view that is rendered by the controller right away
./db/create_items.rb # Database migration file needed for creating repsective table
```
4. Fill those files with the logic you need and run the server again!

## Model
Model in ruBee is just simple ruby object that can be serilalized in the view
in the way it required (ie json).

Here below is a simple example on how it can be used by rendering json from in memory object

```ruby
  #ApplesController

  def show
    # in memory example
apples = [Apple.new(colour: 'red', weight: '1lb'), Apple.new(colour: 'green', weight: '1lb')]
    apple = apples.find { |apple| apple.colour = params[:colour] }

    response_with object: apple, type: :json
  end
```

Just make sure Serializable module included in the target class.
```ruby
  class Apple
    include Serializable
    attr_accessor :id, :colour, :weight
  end
```
However, you can simply turn it to ORM object by extending database class.

```Ruby
  class Apple < Rubee::SequelObject
    attr_accessor :id, :colour, :weight
  end
```
Rubee::SequelObject methods:
### Save record in db
- `apple.save`
### Destroy record and all related records
- `apple.destroy(cascade: true)` # default false
### Update record with new value
- `apple.update(colour: 'red')`
### Check wheter it includes id
- `apple.persisted?`
### reloading the Rubee object by fetching it from the database
- `apple.reload`
### Assign attributes without persisiting it to db
- `apple.assign_attributes(colour: 'red', weight: '1lb')`
### Get last record
- `Apple.last`
### Get all records scoped by colour field
- `Apple.where(colour: 'red')`
### Get last record
- `Apple.last`
### Get all records
- `Apple.all`
### Create new record
- `Apple.create(colour: 'red', weight: '1lb')`
### Destroy all records one by one
- `Apple.destroy_all`
### Use complex queries chains and when ready serialize it back to Rubee object
- `Comment.dataset.join(:posts, comment_id: :id)
          .where(comment_id: Comment.where(text: "test").last.id)
          .then { |dataset| Comment.serialize(dataset) }`
...

So in the controller you would need to query your target object now.

```ruby
  #ApplesController

  def show
    apple = Apple.where(colour: params[:colour])&.last

    if apple
      response_with object: apple, type: :json
    else
      response_with object: { error: "apple with colour #{params[:colour]} not found" }, status: 422, type: :json
    end
  end
```

## Views
View in ruBee is just a plain html/erb file that can be rendered from the controller.

## Object hooks

In ruBee by extending Hookable module any Ruby object can be charged with hooks (logic),
that can be executed before, after and around a specific method execution.

Here below a controller example. However it can be used in any Ruby object, like Model etc.
```ruby
# base conrteoller is hopokable by Default
class ApplesController < Rubee::BaseController
  before :index, :print_hello # you can useinstance method as a handler
  after :index, -> { puts "after index" }, if: -> { true } # or you can use lambda
  after :index, -> { puts "after index2" }, unless: -> { false } # if, unless guards may accept method or lambda
  around :index, :log

  def index
    response_with object: { test: "hooks" }
  end

  def print_hello
    puts "hello!"
  end

  def log
    puts "before log aroud"
    res = yield
    puts "after log around"
    res
  end
  ...
end
```
Then, in the server logs we could see next execution stack

```bash
before log aroud
hello!
after index
after index2
after log around
127.0.0.1 - - [17/Feb/2025:11:42:14 -0500] "GET /apples HTTP/1.1" 401 - 0.0359
```

## JWT based authentification
Charge you rpoject with token based authentification system and customize it for your needs.
include AuthTokenable module to your controller and authentificate any action you need.

Make sure you have initiated User model which is a part of the logic.
```bash
rubee db run:create_users
```
This will create table users and initiate first user with demo credentials.
email: "ok@ok.com", password: "password"
Feel free to customize it in the /db/create_users.rb file before running migration.

Then in the controller you can include the AuthTokenable module and use its methods:
```ruby
class UsersController < Rubee::BaseController
  include AuthTokenable
  # List methods you want to restrict
  auth_methods :index # unless the user is authentificated it will return unauthentificated

  # GET /users/login (login form page)
  def edit
    response_with
  end

  # POST /users/login (login logic)
  def login
    if authentificate! # AuthTokenable method that init @token_header
      # Redirect to restricted area, make sure headers: @token_header is passed
      response_with type: :redirect, to: "/users", headers: @token_header
    else
      @error = "Wrong email or password"
      response_with render_view: "users_edit"
    end
  end

  # POST /usres/logout (logout logic)
  def logout
    unauthentificate! # AuthTokenable method aimed to handle logout action.
    # Make sure @zeroed_token_header is paRssed within headers options
    response_with type: :redirect, to: "/users/login", headers: @zeroed_token_header
  end

  # GET /users (restricted endpoint)
  def index
    response_with object: User.all, type: :json
  end
end
```

## Rubee commands
```bash
rubee start # start the server
rubee start_dev # start the server in dev mode, which restart server on changes
rubee stop # stop the server
rubee restart # restart the server
```

## Generate commands
```bash
rubee generate get /apples # generate controller view, model and migration if set in the routes
```

## Migraiton commands
```bash
rubee db run:create_apples # where create_apples is the name of the migration file, located in /db folder
rubee db structure # generate migration file for the database structure
```

## Rubee console
```bash
rubee console # start the console
```

## Testing
```bash
rubee test # run all tests
rubee test auth_tokenable_test.rb # run specific tests
```
If you want to run any ruBee command within a specific ENV make sure you added it before a command.
For instance if you want to run console in test environment you need to run the following command

```bash
RACK_ENV=test rubee console
```

## Background jobs
Set your background job engine with ease!

### Sidekiq engine
1. Add sidekiq to your Gemfile
```bash
gem 'sidekiq'
```
2. Configure adapter for desired env
```ruby
# config/base_configuration.rb

Rubee::Configuration.setup(env=:development) do |config|
  config.database_url = { url: "sqlite://db/development.db", env: }
  config.async_adapter = { async_adapter: SidekiqAsync, env: }
end
```
3. Bundle up
```bash
bundle install
```
4. Make sure redis is installed and running
```bash
redis-server
```
5. Add sidekiq configuration file
```bash
# config/sidekiq.yml

development:
  redis: redis://localhost:6379/0
  concurrency: 5
  queues:
    default:
    low:
    high:
```
6. Create sidekiq worker
```ruby
# app/async/test_async_runner.rb
require_relative 'extensions/asyncable' unless defined? Asyncable

class TestAsyncRunnner
  include Rubee::Asyncable
  include Sidekiq::Worker

  sidekiq_options queue: :default

  def perform(options)
    User.create(email: options['email'], password: options['password'])
  end
end
```
7. Use it in the code base
```ruby
TestAsyncRunnner.new.perform_async(options: {"email"=> "new@new.com", "password"=> "123"})
```
### Default engine is ThreadAsync
However it is not yet recommended for production. Use it with cautions!
1. Do not define any adapter in the /config/base_configuration.rb file, so default ThreadAsync will be taken.
2. Just create a worker and process it.
```ruby
# test_async_runner.rb
class TestAsyncRunnner
  include Rubee::Asyncable

  def perform(options)
    User.create(email: options['email'], password: options['password'])
  end
end

TestAsyncRunnner.new.perform_async(options: {"email"=> "new@new.com", "password"=> "123"})
```

## TODOs
- [x] Token authorization API
- [ ] Document authorization API
- [ ] Add test coverage
- [ ] Fix bugs
