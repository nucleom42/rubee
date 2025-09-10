![Tests](https://github.com/nucleom42/rubee/actions/workflows/test.yml/badge.svg)
![License](https://img.shields.io/github/license/nucleom42/rubee)
![Gem](https://img.shields.io/gem/dt/ru.Bee.svg)
![GitHub last commit](https://img.shields.io/github/last-commit/nucleom42/rubee.svg)
![Gem](https://img.shields.io/gem/v/ru.Bee.svg)
![GitHub Repo stars](https://img.shields.io/github/stars/nucleom42/rubee?style=social)


# <img src="lib/images/rubee.svg" alt="RUBEE" height="40"> ... RUBEE

Rubee is a Ruby-based framework designed to streamline the development of modular monolith applications. \
It offers a structured approach to building scalable, maintainable, and React-ready projects, \
making it an ideal choice for developers seeking a balance between monolithic simplicity and modular flexibility.

Want to get a quick API server up and runing? You can do it for real quick!
<br />
[![Watch the demo](https://img.youtube.com/vi/ko7H70s7qq0/hqdefault.jpg)](https://www.youtube.com/watch?v=ko7H70s7qq0)

## Production ready

Take a look on the rubee demo site with all documentation stored in there: https://rubee.duckdns.org
Want to explore how it built? https://github.com/nucleom42/rubee-site

## Stress tested

```bash
wrk -t4 -c100 -d30s https://rubee.duckdns.org/docs
Running 30s test @ https://rubee.duckdns.org/docs
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   304.95ms   33.22ms 551.86ms   90.38%
    Req/Sec    82.25     42.37   280.00     69.86%
  9721 requests in 30.02s, 4.11MB read
Requests/sec:    323.78
Transfer/sec:    140.07KB
```

- Short output explanation:
- Requests/sec: ~324
- Average latency: ~305 ms
- Total requests handled: 9,721
- Hardware: Raspberry Pi 5(8 Gb) (single board computer)
- Server: Rubee app hosted via Nginx + HTTPS

This demonstrates RUBEE’s efficient architecture and suitability for lightweight deployments — even on low-power hardware.

## Content

- [Installation](#installation)
- [Run tests](#run-tests)
- [Draw contract](#draw-contract)
- [Model](#model)
- [Routing](#routing)
- [Database](#database)
- [Views](#views)
- [Hooks](#hooks)
- [JWT based authentification](#jwt-based-authentification)
- [Rubee commands](#rubee-commands)
- [Generate commands](#generate-commands)
- [Migration commands](#migration-commands)
- [Rubee console](#rubee-console)
- [Testing](#testing)
- [Background jobs](#background-jobs)
- [Modular](#modualar-application)
- [Logger](#logger)

You can read it on the demo [site](https://rubee.duckdns.org/docs).
The doc site is off now. Will be restored shortly. We are working on it.
Please for the meantime, refer to downbelow documentation.
Sorry for inconviniences.

## Features

Lightweight – A minimal footprint focused on serving Ruby applications efficiently.
<br>
Modular – A modular approach to application development. Build modular monoliths with ease by attaching \
as many subprojects as you need.
<br>
Contract-driven – Define your API contracts in a simple, declarative way, then generate all the boilerplate you need.
<br>
Fast – Optimized for speed, providing quick responses. (Everything is relative, we know! 😄)
<br>
Rack-powered – Built on Rack. The full Rack API is available for easy integration.
<br>
Databases – Supports SQLite3, PostgreSQL, MySQL, and more via the Sequel gem.
<br>
Views – JSON, ERB, and plain HTML out of the box.
<br>
React Ready – React is supported as a first-class Rubee view engine.
<br>
Bundlable – Charge your Rubee app with any gem you need. Update effortlessly via Bundler.
<br>
ORM-agnostic – Models are native ORM objects, but you can use them as blueprints for any data source.
<br>
Authenticatable – Easily add JWT authentication to any controller action.
<br>
Hooks – Add logic before, after, or around any controller action.
<br>
Testable – Run all or selected tests using fast, beloved Minitest.
<br>
Asyncable – Plug in async adapters and use any popular background job engine.
<br>
Console – Start an interactive console and reload on the fly.
<br>
Background Jobs – Schedule and process background jobs using your preferred async stack.

## Installation

1. Install RUBEE
```bash
gem install ru.Bee
```

2. Create your first project
```bash
rubee project my_project

cd my_project
```

[Back to content](#content)

3. Install dependencies

***Prerequisites***<br />
Make sure:
**Ruby** language (3.1>) is installed
**Bundler** is installed

```bash
bundle install
```

4. Run RUBEE server. Default port is 7000
```bash
rubee start # or rubee start_dev for development

# Sarting from veriosn 1.8.0, you can also start you rubee server with yjit compiler and enjoy speed boost.
rubee start --jit=yjit
# Option is available for dev environment too
rubee start_dev --jit=yjit
```

5. Open your browser and go to http://localhost:7000

## Run tests
```bash
rubee test
# or you can specify specific test file
rubee test models/user_model_test.rb
```
[Back to content](#content)

## Draw contract

1. Add the routes to the routes.rb
    ```ruby
    Rubee::Router.draw do |router|
      ...
      # draw the contract
      router.get "/apples", to: "apples#index",
        model: {
          name: "apple",
          attributes: [
            { name: 'id', type: :primary },
            { name: 'colour', type: :string },
            { name: 'weight', type: :integer }
          ]
        }
    end
    ```

2. generate the files
```bash
    rubee generate get /apples
```
This will generate the following files
```bash
  ./app/controllers/apples_controller.rb # Controller with respective action
  ./app/views/apples_index.erb # ERB view that is rendered by the controller right away
  ./app/models/apple.rb # Model that acts as ORM
  ./db/create_apples.rb # Database migration file needed for creating repsective table
```

3. Run the initial db migration
```bash
    rubee db run:all
```

4. Fill the generated files with the logic you need and run the server again!

[Back to content](#content)

## Model
Model in RUBEE is just simple ruby object that can be serilalized in the view
in the way it required (ie json).
Here below is a simple example on how it can be used by rendering json from in memory object

```ruby
  #ApplesController

  def show
    # In memory example
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

However, you can simply turn it to ORM object by extending database class Rubee::SequelObject.
This one is already serializable and charged with hooks.
```Ruby
  class Apple < Rubee::SequelObject
    attr_accessor :id, :colour, :weight
  end
```

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

[Back to content](#content)

#### Rubee::SequelObject base methods

Initiate new record in memory
```Ruby
irb(main):015> user = User.new(email: "llo@ok.com", password: 543)
=> #<User:0x000000010cda23b8 @email="llo@ok.com", @password=543>
```

Save record in db
```Ruby
=> #<User:0x000000010cda23b8 @email="llo@ok.com", @password=543>
irb(main):018> user.save
=> true
```

Update record with new value
```Ruby
irb(main):019> user.update(email: "update@email.com")
=> #<User:0x000000010c39b298 @email="update@email.com", @id=3, @password="543">
```

Check whether it includes id
```Ruby
irb(main):015> user = User.new(email: "llo@ok.com", password: 543)
=> #<User:0x000000010cda23b8 @email="llo@ok.com", @password=543>
irb(main):016> user.persisted?
=> false
```

Get the record from the database
```Ruby
irb(main):011> user = User.last
=> #<User:0x000000010ccea178 @email="ok23@ok.com", @id=2, @password="123">
irb(main):012> user.email = "new@ok.com"
=> "new@ok.com"
irb(main):013> user
=> #<User:0x000000010ccea178 @email="new@ok.com", @id=2, @password="123">
irb(main):014> user.reload
=> #<User:0x000000010c488548 @email="ok23@ok.com", @id=2, @password="123"> # not persited data was updated from db
```

Assign attributes without persisiting it to db
```Ruby
irb(main):008> User.last.assign_attributes(email: "bb@ok.com")
=> {"id" => 2, "email" => "ok23@ok.com", "password" => "123"
```

Get all records scoped by field
```Ruby
irb(main):005> User.where(email: "ok23@ok.com")
=> [#<User:0x000000010cfaa5c0 @email="ok23@ok.com", @id=2, @password="123">]
```

Get all record
```Ruby
irb(main):001> User.all
=> [#<User:0x000000010c239a30 @email="ok@ok.com", @id=1, @password="password">]
```
Find by id
```Ruby
irb(main):002> user = User.find 1
=> #<User:0x000000010c2f7cd8 @email="ok@ok.com", @id=1, @password="password">
```

Get last record
```Ruby
irb(main):003> User.last
=> #<User:0x000000010c2f7cd8 @email="ok@ok.com", @id=1, @password="password">
```

Create new persited record
```Ruby
irb(main):004> User.create(email: "ok23@ok.com", password: 123)
=> #<User:0x000000010c393818 @email="ok23@ok.com", @id=2, @password=123>
```

Destroy record and all related records
```Ruby
irb(main):021> user.destroy(cascade: true)
=> 1
```

Destroy all records one by one
```Ruby
irb(main):022> User.destroy_all
=> [#<User:0x000000010d42df98 @email="ok@ok.com", @id=1, @password="password">, #<User:0x000000010d42de80 @email="ok23@ok.com", @id=2, @password="123">
irb(main):023> User.all
=> []
```

Use complex queries chains and when ready serialize it back to Rubee object.
```Ruby
# user model
class User < Rubee::SequelObject
  attr_accessor :id, :email, :password
  owns_many :comments, over: :posts
end

# comment model
class Comment < Rubee::SequelObject
  attr_accessor :id, :text, :user_id
  owns_many :users, over: :posts
end

# join post model
class Post < Rubee::SequelObject
  attr_accessor :id, :user_id, :comment_id
  holds :comment
  holds :user
end
```

```Ruby
irb(main):001> comment = Comment.new(text: "test")
irb(main):002> comment.save
irb(main):003> user = User.new(email: "ok-test@test.com", password: "123")
irb(main):004> user.save
irb(main):005> post = Post.new(user_id: user.id, comment_id: comment.id)
irb(main):006> post.save
=> true
irb(main):007> comment
=> #<Comment:0x000000012281a650 @id=21, @text="test">
irb(main):008> result = Comment.dataset.join(:posts, comment_id: :id)
irb(main):009>  .where(comment_id: Comment.where(text: "test").last.id)
irb(main):010>  .then { |dataset| Comment.serialize(dataset) }
=> [#<Comment:0x0000000121889998 @id=30, @text="test", @user_id=702>]
```
This is recommended when you want to run one query and serialize it back to Rubee object only once.
So it may safe some resources.

[Back to content](#content)

## Mysqlite production ready
Starting from verison 1.9.0 main issue for using sqlite - write db lock is resolved!
If you feel comfortable you can play with retry configuration parameters:

```ruby
  ## configure db write retries
  config.db_max_retries = { env:, value: 3 } # set it to 0 to disable or increase if needed
  config.db_retry_delay = { env:, value: 0.1 }
  config.db_busy_timeout = { env:, value: 1000 } # this is busy timeout in ms, before raising bussy error
```

For Rubee model class persist methods create and update retry will be added automatically. However, \
if you want to do it with Sequel dataset you need to do it yourself:

```ruby
  Rubee::DBTools.with_retry { User.dataset.insert(email: "test@ok.com", password: "123") }
```
[Back to content](#content)

## Routing
Rubee uses explicit routes. In the routes.rb yout can define routes for any of the main HTTP methods. \
You can also add any matched parameter denoted by a pair of `{ }` in the path of the route. \
Eg. `/path/to/{a_key}/somewhere`

### Routing methods
``` ruby
Rubee::Router.draw do |router|
  router.get '/posts', to: 'posts#index'
  router.post '/posts', to: 'posts#create'
  router.patch '/posts/{id}', to: 'posts#update'
  router.put '/posts/{id}', to: 'posts#update'
  router.delete '/posts/{id}', to: 'posts#delete'
  router.head '/posts', to: 'posts#index'
  router.connect '/posts', to: 'posts#index'
  router.options '/posts', to: 'posts#index'
  router.trace '/posts', to: 'posts#index'
end
```

As you see above every route is set up as:\
```ruby
route.{http_method} {path}, to: "{controller}#{action}",
  model { ...optional }, namespace { ...optional }, react { ...optional }
```

### Defining Model attributes in routes
One of Rubee's unique traits is where we can define our models for generation. \
You've seen above one possible way you can set up.

```ruby
Rubee::Router.draw do |router|
  ...
  # draw the contract
  router.get "/apples", to: "apples#index",
    model: {
      name: "apple",
      attributes: [
        { name: 'id', type: :primary },
        { name: 'colour', type: :string },
        { name: 'weight', type: :integer }
      ]
    }
end
```

There are many other types supported by us and Sequel to help generate your initial db files. \
Other supported attribute key types are:
``` ruby
[
  { name: 'id', type: :primary},
  { name: 'name', type: :string },
  { name: 'description', type: :text },
  { name: 'quntity', type: :integer },
  { name: 'created', type: :date },
  { name: 'modified', type: :datetime },
  { name: 'exists', type: :time },
  { name: 'active', type: :boolean },
  { name: 'hash', type: :bigint },
  { name: 'price', type: :decimal },
  { name: 'item_id', type: :foreign_key },
  { name: 'item_id_index', type: :index },
  { name: 'item_id_unique', type: :unique }
]
```
Every attribute can have a set of options passed based on their related \
[Sequel schema definition](https://github.com/jeremyevans/sequel/blob/master/doc/schema_modification.rdoc).

An example of this would be for the type string: \
```ruby
{name: 'key', type: :string, options: { size: 50, fixed: true } }
```

Gets translated to:\
```
rubyString :key, size: 50, fixed: true
```

### Generation from routes
As long as you have a `{ model: 'something' }` passed to your given route, \
you can use it to generate your initial model files. If only a `path` and a `to:` are defined will only generate \
a controller and a corresponding view.

To generate based on a get route for the path /apples:\
```ruby
rubee generate get /apples # or rubee gen get /apples
```

To generate base on a patch request for the path /apples/{id}:\
```ruby
rubee generate patch /apples/{id} # or rubee gen patch /apples/{id}
```

Example:
```ruby
Rubee::Router.draw do |router|
  ...
  # draw the contract
  router.get "/apples", to: "apples#index"
end
```
Will Generate:
```bash
./app/controllers/apples_controller.rb # Controller with respective action
./app/views/apples_index.erb # ERB view that is rendered by the controller right away
```

Example 2:
```ruby
Rubee::Router.draw do |router|
  ...
  # draw the contract
  router.get "/apples", to: "apples#index", model: { name: 'apple' }
end
```

Will generate:
```bash
./app/controllers/apples_controller.rb # Controller with respective action
./app/views/apples_index.erb # ERB view that is rendered by the controller right away
./app/models/apple.rb # Model that acts as ORM
./db/create_apples.rb # Database migration file needed for creating repsective table
```

Example 3:
```ruby
Rubee::Router.draw do |router|
  ...
  # draw the contract
  router.get "/apples", to: "apples#index",
    model: {
      name: 'apple',
      attributes: [
        { name: 'id', type: :primary },
        { name: 'colour', type: :string },
        { name: 'weight', type: :integer }
      ]
    }
end
```

Will generate:
```bash
./app/controllers/apples_controller.rb # Controller with respective action
./app/models/apple.rb # Model that acts as ORM
./app/views/apples_index.erb # ERB view that is rendered by the controller right away
./db/create_apples.rb # Database migration file needed for creating repsective table
```


### Modualar application

You can also use RUBEE to create modular applications.\
And attach as many subprojects you need.
Main philosophy of attach functinality is to keep the main project clean and easy to maintain. It will still\
share data with the main app. So where to define a border between the main app and subprojects is up to developer.
Howerver by attching new subproject you will get a new folder and files configured and namespaced respectively.

So if you need to extend your main app with a separate project, you can do it easily in RUBEE.
1. Attach new subrpoject

```bash
rubee attach admin
```
This will create a dedicated folder in the project root called admin and all the MVC setup, route and configuraion \
files will be created there.

2. Add routes

```ruby
# admin_routes.rb
Rubee::Router.draw do |router|
  ...
  # draw the contract
  router.get '/admin/cabages', to: 'cabages#index',
                               model: {
                                 name: 'cabage',
                                 attributes: [
                                   { name: 'id', type: :primary },
                                   { name: 'name', type: :string }
                                 ]
                               },
                               namespace: :admin # mandatory option for supporting namespacing
end
```

3. Run gen command

```bash
rubee gen get /admin/cabages app:admin
```

This will generate the bolierplate files:

```bash
./admin/controllers/cabages_controller.rb
./admin/views/cabages_index.erb
./admin/models/cabage.rb
./db/create_cabages.rb
```

4. Perform migrations

```bash
rubee db run:create_cabages
```

5. Fill the views and controller with the content

```ruby
# ./admin/controllers/cabages_controller.rb
class Admin::CabagesController < Rubee::BaseController
  def index
    response_with object: Cabage.all, type: :json
  end
end
```

6. Run the rubee server

```bash
rubee start # or rubee start_dev for development
```

[Back to content](#content)

## Views
View in RUBEE is just a plain html/erb/react file that can be rendered from the controller.

## Templates over erb

You can use erb as a template engine in the views.

layout.erb is the parent template that is rendered first and then the child templates are rendered inside it.
Feel free to include you custom css and js files in the this file.

```ruby
# app/controllers/welcome_controller.rb

class WelcomeController < Rubee::BaseController
  def show
    response_with object: { message: 'Hello, world!' }
  end
end
```

```erb
# app/views/welcome_header.erb

<h1>All set up and running!</h1>
```

```erb
# app/views/welcome_show.erb

<div class="container">
    <%= render_template :welcome_header %> # you can easily attach erb temlate using render_template method
    <p><%= locals[:object][:message] %></p> # displaying, passed in the controller object
</div>
```

## React as a view

React is supported out of the box in the rubee view.
Make react as a view representation layer is easy.

Prerequisites: Node and NPM are required

1. Make sure after creating project and bundling you have installed react dependencies by

```bash
rubee react prepare # this will install react related node modules
```

2. Make sure you have configured react in the configuration file

```ruby
# config/base_configuration/rb
Rubee::Configuration.setup(env = :development) do |config|
  config.database_url = { url: 'sqlite://db/development.db', env: }

  # this line registers react as a view
  config.react = { on: true, env: }
end
```

3. Start server by

```bash
rubee start
# It will start to server on port 7000 (default)
# You can change it by

rubee start --port=3000
```

3. Open your browser and navigate to http://localhost:3000/home

4. You will see the react app running in the browser.

5. For development purposes make sure you run `rubee start_dev` and in other terminal window run `rubee react watch`.
So that will ensure all cahnges applying instantly.

6. You can generate react view from the route by indicating the view name explicitly

```ruby
# config/routes.rb
Rubee::Router.draw do |router|
  router.get('/', to: 'welcome#show') # override it for your app

  router.get('/api/users', to: 'user#index', react: { view_name: 'users.tsx' })
  # Please note /api/users here is the backend endpoint
  # For rendering generated /app/views/users.tsx file, you need to update react routes
end
```

7. Add logic to generated api controller

```ruby
# app/controllers/api/user_controller.rb
class Api::UserController < Rubee::BaseController
  def index
    response_with object: User.all, type: :json
  end
end
```
8. Register path in react routes

```javascript
// app/views/app.tsx
<Router>
  <Routes>
    <Route path="/users" element={<Users />} />
    <Route path="*" element={<NotFound />} />
  </Routes>
</Router>
```
9. Fetch data from the backend in the users.tsx react component and display it in the browser http://localhost:3000/users

```javascript
# app/views/users.tsx
import { useState, useEffect } from 'react';

function Users() {
  const [users, setUsers] = useState([]);

  useEffect(() => {
    fetch('/api/users')
      .then(response => response.json())
      .then(data => setUsers(data));
  }, []);

  return (
    <div>
      <h1>Users</h1>
      <ul>
        {users.map(user => (
          <li key={user.id}>id: {user.id}: {user.name}</li>
        ))}
      </ul>
    </div>
  );
}

```
[Back to content](#content)

## Object hooks

In RUBEE by extending Hookable module any Ruby object can be charged with hooks (logic),
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

[Back to content](#content)

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

[Back to content](#content)

## Rubee commands
```bash
rubee start # start the server
rubee start_dev # start the server in dev mode, which restart server on changes
rubee react prepare # install react dependencies
rubee react watch # dev mode for react, works together with start_dev
rubee stop # stop the server
rubee restart # restart the server
```

## Generate commands
```bash
rubee generate get /apples # generate controller view, model and migration if set in the routes
```

## Migraiton commands
```bash
rubee db run:all # run all migrations
rubee db run:create_apples # where create_apples is the name of the migration file, located in /db folder
rubee db structure # generate migration file for the database structure
```

## Rubee console
```bash
rubee console # start the console
# you can reload the console by typing reload, so it will pick up latest changes
```

## Testing
```bash
rubee test # run all tests
rubee test auth_tokenable_test.rb # run specific tests
```

[Back to content](#content)


If you want to run any RUBEE command within a specific ENV make sure you added it before a command.
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

[Back to content](#content)

### Logger

You can use your own logger by setting it in the /config/base_configuration.rb.

```ruby
# config/base_configuration.rb
Rubee::Configuration.setup(env=:development) do |config|
  config.database_url = { url: "sqlite://db/development.db", env: }
  config.logger = { logger: MyLogger, env: }
end
```

Or you can use the default logger.
Let's consider example with welcome controller and around hook:
```ruby
# app/controllers/welcome_controller.rb
class WelcomeController < Rubee::BaseController
  around :show, ->(&target_method) do
    start = Time.now
    Rubee::Logger.warn(message: 'This is a warning message', method: :show, class_name: 'WelcomeController')
    Rubee::Logger.error(message: 'This is a warning message', class_name: 'WelcomeController')
    Rubee::Logger.critical(message: 'We are on fire!')
    target_method.call
    Rubee::Logger.info(
      message: "Execution Time: #{Time.now - start} seconds",
      method: :show,
      class_name: 'WelcomeController'
    )
    Rubee::Logger.debug(object: User.last, method: :show, class_name: 'WelcomeController')
  end

  def show
    response_with
  end
end
```
When you trigger the controller action, the logs will look like this:

```bash
[2025-04-26 12:32:33] WARN [method: show][class_name: WelcomeController] This is a warning message
[2025-04-26 12:32:33] ERROR [class_name: WelcomeController] This is a warning message
[2025-04-26 12:32:33] CRITICAL We are on fire!
[2025-04-26 12:32:33] INFO [method: show][class_name: WelcomeController] Execution Time: 0.000655 seconds
[2025-04-26 12:32:33] DEBUG [method: show][class_name: WelcomeController] #<User:0x000000012c5c63e0 @id=4545, @email="ok@op.com", @password="123">
```

[Back to content](#content)

### Contributing

If you are interested in contributing to RUBEE,
please read the [Contributing](https://github.com/nucleom42/rubee/blob/main/CONTRIBUTING.md) guide.
Also feel free to open an [issue](https://github.com/nucleom42/rubee/issues) if you apot one.
Have an idea or you wnat to discuss something?
Please open a [discussion](https://github.com/nucleom42/rubee/discussions)

## License
This project is released under the [MIT License](https://github.com/nucleom42/rubee/blob/main/LICENSE).
