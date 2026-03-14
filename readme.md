![Tests](https://github.com/nucleom42/rubee/actions/workflows/test.yml/badge.svg)
![License](https://img.shields.io/github/license/nucleom42/rubee)
![Gem](https://img.shields.io/gem/dt/ru.Bee.svg)
![GitHub last commit](https://img.shields.io/github/last-commit/nucleom42/rubee.svg)
![Gem](https://img.shields.io/gem/v/ru.Bee.svg)
![GitHub Repo stars](https://img.shields.io/github/stars/nucleom42/rubee?style=social)

<img width="358" height="131" alt="Screen Shot 2026-03-10 at 6 26 04 PM" src="https://github.com/user-attachments/assets/9f156847-590d-43c2-b432-728e6cc2eacc" />
<br />
<img width="200" alt="Screenshot 2026-03-11 at 3 42 16 PM" src="https://github.com/user-attachments/assets/f2df9bc7-cda9-4d91-83d5-deedd499999b" />


ru.Bee is a Ruby-based web framework designed to streamline the development of modular monolith web applications.
Under the hood, it leverages the power of Ruby and Rack backed by Puma, offering a clean, efficient, and flexible architecture.
It offers a structured approach to building scalable, maintainable, and React-ready projects,
making it an ideal choice for developers seeking a balance between monolithic simplicity and modular flexibility.

Want to get a quick API server up and running? You can do it in no time!
<br />
[![Watch the demo](https://img.youtube.com/vi/ko7H70s7qq0/hqdefault.jpg)](https://www.youtube.com/watch?v=ko7H70s7qq0)

Starting from ru.Bee 2.0.0, ru.Bee supports WebSocket, which allows you to build real-time applications with ease.
<br />
[![Watch the demo](https://img.youtube.com/vi/gp8IheKBNm4/hqdefault.jpg)](https://www.youtube.com/watch?v=gp8IheKBNm4)

## Production ready

Take a look at the ru.Bee demo site with full documentation: https://rubee.dedyn.io/
Want to explore how it was built? https://github.com/nucleom42/rubee-site

## Stress tested

```bash
wrk -t4 -c100 -d30s https://rubee.dedyn.io/docs
Running 30s test @ https://rubee.dedyn.io/docs
  4 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   304.95ms   33.22ms 551.86ms   90.38%
    Req/Sec    82.25     42.37   280.00     69.86%
  9721 requests in 30.02s, 4.11MB read
Requests/sec:    323.78
Transfer/sec:    140.07KB
```

Short output explanation:

- Requests/sec: ~324
- Average latency: ~305 ms
- Total requests handled: 9,721
- Hardware: Raspberry Pi 5 (8 GB) — single board computer
- Server: ru.Bee app hosted via Nginx + HTTPS

This demonstrates ru.Bee's efficient architecture and suitability for lightweight deployments — even on low-power hardware.

## Comparison

Here is a short web frameworks comparison built with Ruby, so you can evaluate your choice with ru.Bee.

**Disclaimer:**
The comparison is based on generic and subjective information available on the internet and is not a real benchmark. It is aimed at giving you a general idea of the differences between the frameworks and is not intended as a direct comparison.

| Feature / Framework | **ru.Bee** | Rails | Sinatra | Hanami | Padrino | Grape |
|---------------------|-----------|-------|---------|--------|---------|-------|
| **React readiness** | Built-in React integration (route generator can scaffold React components that fetch data via controllers) | React via webpacker/importmap, but indirect | No direct React support | Can integrate React | Can integrate via JS pipelines | API-focused, no React support |
| **Routing style**   | Explicit, file-based routes with clear JSON/HTML handling | DSL, routes often implicit inside controllers | Explicit DSL, inline in code | Declarative DSL | Rails-like DSL | API-oriented DSL |
| **Modularity**      | Lightweight core, pluggable projects | One project by default, but can be extended with respective gem | Very modular (small DSL) | Designed for modularity | Semi-modular, still Rails-like | Modular (mount APIs) |
| **Startup / Load speed** | Very fast (minimal boot time, designed for modern Ruby) | Not very fast, especially on large apps | Very fast | Medium (slower than Sinatra, faster than Rails) | Similar to Rails (heavier) | Fast |
| **Ecosystem**       | Early-stage, focused on modern simplicity, but easily expandable via Bundler | Huge ecosystem, gems, community | Large ecosystem, many gems work | Small, growing | Small, less active | Small, niche |
| **Learning curve**  | Simple, explicit, minimal DSL | Steep (lots of conventions & magic) | Very low (DSL fits in one file) | Medium, more concepts (repositories, entities) | Similar to Rails, easier in parts | Low (API-only) |
| **Customizability** | High (explicit over implicit, hooks & generators) | Limited without monkey-patching | Very high (you control flow) | High, modular architecture | Medium | High (designed for APIs) |
| **Target use case** | Modern full-stack apps with React frontends or APIs; well-suited if you prefer modular monolith over microservices | Large, full-stack, mature apps | Small apps, microservices | Modular apps, DDD | Rails-like but modular | APIs & microservices |
| **Early adopters support** | Personal early adopters support via fast extending and fixing | Not available | Not known | Not known | Not known | Not known |

## Content

- [Installation](#installation)
- [Run tests](#run-tests)
- [Draw contract](#draw-contract)
- [Model](#model)
- [Routing](#routing)
- [Database](#database)
- [Views](#views)
- [Object hooks](#object-hooks)
- [Validations](#validations)
- [JWT based authentication](#jwt-based-authentication)
- [OAuth authentication](#oauth-authentication)
- [ru.Bee commands](#rubee-commands)
- [Generate commands](#generate-commands)
- [Migration commands](#migration-commands)
- [ru.Bee console](#rubee-console)
- [Rubee::Support](#rubee-support)
- [Testing](#testing)
- [Background jobs](#background-jobs)
- [Sidekiq engine](#sidekiq-engine)
- [ThreadAsync engine](#threadasync-engine)
- [Modular application](#modular-application)
- [Logger](#logger)
- [WebSocket](#websocket)
- [Bee assistant](#bee-assistant)
- [Middleware integration](#middleware-integration)


You can read the full docs on the demo site: [rubee.dedyn.io](https://rubee.dedyn.io/)

## Features

Lightweight – A minimal footprint focused on serving Ruby applications efficiently.
<br>
Modular – A modular approach to application development. Build a modular monolith app with ease by attaching as many subprojects as you need.
<br>
Contract-driven – Define your API contracts in a simple, declarative way, then generate all the boilerplate you need.
<br>
Fast – Optimized for speed, providing quick responses.
<br>
Rack-powered – Built on Rack. The full Rack API is available for easy integration.
<br>
Databases – Supports SQLite3, PostgreSQL, MySQL, and more via the Sequel gem.
<br>
Views – JSON, ERB, and plain HTML out of the box.
<br>
React Ready – React is supported as a first-class ru.Bee view engine.
<br>
Bundlable – Charge your ru.Bee app with any gem you need. Update effortlessly via Bundler.
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
<br>
WebSocket – Serve and handle WebSocket connections.
<br>
Logger – Use any logger you want.

## Installation

1. Install ru.Bee
```bash
gem install ru.Bee
```

2. Create your first project
```bash
rubee project my_project

cd my_project
```

3. Install dependencies

Prerequisites: make sure **Ruby** (3.1 or higher, 3.4.1 recommended) and **Bundler** are installed.

```bash
bundle install
```

4. Run the ru.Bee server. Default port is 7000.
```bash
rubee start # or rubee start_dev for development

# Starting from version 1.8.0, you can also start the server with the yjit compiler for a speed boost.
rubee start --jit=yjit
# This option is available for the dev environment too.
rubee start_dev --jit=yjit
```

5. Open your browser and go to http://localhost:7000

## Run tests

```bash
rubee test
# or specify a specific test file
rubee test models/user_model_test.rb
# or run a specific line in the test file
rubee test models/user_model_test.rb --line=12
```

## Draw contract

1. Add the routes to `routes.rb`
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
            { name: 'weight', type: :integer },
            { name: 'created', type: :datetime },
            { name: 'updated', type: :datetime },
          ]
        }
    end
    ```

2. Generate the files
```bash
rubee generate get /apples
```
This will generate the following files:
```bash
./app/controllers/apples_controller.rb # Controller with respective action
./app/views/apples_index.erb           # ERB view rendered by the controller
./app/models/apple.rb                  # Model that acts as ORM
./db/create_apples.rb                  # Database migration file for the respective table
```

3. Run the initial database migration
```bash
rubee db run:all
```

4. Fill the generated files with the logic you need and run the server again.

5. You can find a full snapshot of the schema in the `STRUCTURE` constant or in the `db/structure.rb` file.

6. Print the latest schema from the `STRUCTURE` constant via the CLI
```bash
-> rubee db schema
--- users
- id, (PK), type (INTEGER)
- email, type (varchar(255))
- password, type (varchar(255))

--- accounts
- id, (PK), type (INTEGER)
- address, type (varchar(255))
- user_id, type (INTEGER)

--- posts
- id, (PK), type (INTEGER)
- user_id, type (INTEGER)
- comment_id, type (INTEGER)

--- comments
- id, (PK), type (INTEGER)
- text, type (varchar(255))
- user_id, type (INTEGER)
```

7. Print the schema for a specific table
```bash
-> rubee db schema posts
--- posts
- id, (PK), type (INTEGER)
- user_id, type (INTEGER), nullable
- comment_id, type (INTEGER), nullable
- created, type (datetime), nullable
- updated, type (datetime), nullable

  Foreign keys:
  - comment_id → comments() on delete no_action on update no_action
  - user_id → users() on delete no_action on update no_action
```

8. Dropping all tables can be handy during development. Be careful and make sure you pass the desired environment.
```bash
RACK_ENV=test rubee db drop_tables
These tables have been dropped for the test env:
[:companies, :company_clients, :services]
```

[Back to content](#content)

## Model

A model in ru.Bee is a simple Ruby object that can be serialized in the view in whatever form is required (e.g. JSON).
Here is a simple example of rendering JSON from an in-memory object:

```ruby
# ApplesController

def show
  # In-memory example
  apples = [Apple.new(colour: 'red', weight: '1lb'), Apple.new(colour: 'green', weight: '1lb')]
  apple = apples.find { |apple| apple.colour = params[:colour] }

  response_with object: apple, type: :json
end
```

Make sure the `Serializable` module is included in the target class:
```ruby
class Apple
  include Serializable
  attr_accessor :id, :colour, :weight
end
```

You can also turn it into an ORM object by extending `Rubee::SequelObject`, which is already serializable and charged with hooks:
```ruby
class Apple < Rubee::SequelObject
  attr_accessor :id, :colour, :weight
end
```

In the controller, query your target object directly:
```ruby
# ApplesController

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

### Rubee::SequelObject base methods

Initiate a new record in memory
```ruby
irb(main):015> user = User.new(email: "llo@ok.com", password: 543)
=> #<User:0x000000010cda23b8 @email="llo@ok.com", @password=543>
```

Save a record to the database
```ruby
irb(main):018> user.save
=> true
```

Update a record with a new value
```ruby
irb(main):019> user.update(email: "update@email.com")
=> #<User:0x000000010c39b298 @email="update@email.com", @id=3, @password="543", @created="2025-09-28 22:03:07.011332 -0400", @updated="2025-09-28 22:03:07.011332 -0400">
```

Check whether a record has been persisted
```ruby
irb(main):016> user.persisted?
=> false
```

Get a record from the database and reload it
```ruby
irb(main):011> user = User.last
=> #<User:0x000000010ccea178 @email="ok23@ok.com", @id=2, @password="123", ...>
irb(main):012> user.email = "new@ok.com"
=> "new@ok.com"
irb(main):014> user.reload
=> #<User:0x000000010c488548 @email="ok23@ok.com", @id=2, @password="123", ...> # unpersisted data refreshed from db
```

Assign attributes without persisting to the database
```ruby
irb(main):008> User.last.assign_attributes(email: "bb@ok.com")
=> {"id" => 2, "email" => "ok23@ok.com", "password" => "123"}
```

Get all records scoped by a field
```ruby
irb(main):005> User.where(email: "ok23@ok.com")
=> [#<User:0x000000010cfaa5c0 @email="ok23@ok.com", @id=2, @password="123">]
```

Get all records
```ruby
irb(main):001> User.all
=> [#<User:0x000000010c239a30 @email="ok@ok.com", @id=1, @password="password", ...>]
```

Find by id
```ruby
irb(main):002> user = User.find 1
=> #<User:0x000000010c2f7cd8 @email="ok@ok.com", @id=1, @password="password", ...>
```

Get the last record
```ruby
irb(main):003> User.last
=> #<User:0x000000010c2f7cd8 @email="ok@ok.com", @id=1, @password="password", ...>
```

Create a new persisted record
```ruby
irb(main):004> User.create(email: "ok23@ok.com", password: 123)
=> #<User:0x000000010c393818 @email="ok23@ok.com", @id=2, @password=123, ...>
```

Destroy a record and all related records
```ruby
irb(main):021> user.destroy(cascade: true)
=> 1
```

Find a record in the database or initialize a new instance for subsequent persistence
```ruby
irb(main):020> user = User.find_or_new(email: "ok23@ok.com")
=> #<User:0x000000010cfaa5c0 @email="ok23@ok.com", @id=2, @password="123">
irb(main):021> user.persisted?
=> true
irb(main):022> user = User.find_or_new(email: "new@ok.com")
=> #<User:0x000000010cfaa5c0 @email="new@ok.com", @id=nil, @password=nil>
irb(main):023> user.persisted?
=> false
```

Destroy all records one by one
```ruby
irb(main):022> User.destroy_all
=> [#<User ...>, #<User ...>]
irb(main):023> User.all
=> []
```

Use complex query chains and serialize results back to ru.Bee objects in a single query:
```ruby
# user model
class User < Rubee::SequelObject
  attr_accessor :id, :email, :password, :created, :updated
  owns_many :comments, over: :posts
end

# comment model
class Comment < Rubee::SequelObject
  attr_accessor :id, :text, :user_id, :created, :updated
  owns_many :users, over: :posts
end

# join post model
class Post < Rubee::SequelObject
  attr_accessor :id, :user_id, :comment_id, :created, :updated
  holds :comment
  holds :user
end
```

```ruby
irb(main):008> result = Comment.dataset.join(:posts, comment_id: :id)
irb(main):009>  .where(comment_id: Comment.where(text: "test").last.id)
irb(main):010>  .then { |dataset| Comment.serialize(dataset) }
=> [#<Comment:0x0000000121889998 @id=30, @text="test", @user_id=702, ...>]
```

Since version 2.6.0, `Rubee::SequelObject` supports chained queries. Supported methods: `where`, `order`, `limit`, `offset`, `all`, `owns_many`, `owns_one`, `join`, `paginate`.

```ruby
irb(main):001> Comment.where(text: "test").where(user_id: 1)
=> [#<Comment:0x0000000121889998 @id=30, @text="test", @user_id=702, ...>]
```

A `paginate` method is also available:
```ruby
irb(main):001> comments = Comment.all.paginate(page: 1, per_page: 3)

irb(main):001> comments.pagination_meta
=> {:current_page=>1, :per_page=>3, :total_count=>10, :first_page=>true, :last_page=>false, :prev=>nil, :next=>2}
```

[Back to content](#content)

## Database

ru.Bee supports Postgres and SQLite databases fully and can potentially be used with any database supported by the Sequel gem.

When using SQLite, include `sqlite3` in your Gemfile:
```ruby
gem 'sqlite3'
```

Define your database URLs for each environment in `config/base_configuration.rb`:
```ruby
Rubee::Configuration.setup(env = :development) do |config|
  config.database_url = { url: 'sqlite://db/development.db', env: }
  ...
end
Rubee::Configuration.setup(env = :test) do |config|
  config.database_url = { url: 'sqlite://db/test.db', env: }
  ...
end
Rubee::Configuration.setup(env = :production) do |config|
  config.database_url = { url: 'sqlite://db/production.db', env: }
  ...
end
```

For PostgreSQL, include the `pg` gem and configure the URLs:
```ruby
gem 'pg'
```

```ruby
Rubee::Configuration.setup(env = :development) do |config|
  config.database_url = { url: "postgres://postgres@localhost:5432/development", env: }
  ...
end
Rubee::Configuration.setup(env = :test) do |config|
  config.database_url = { url: "postgres://postgres@localhost:5432/test", env: }
  ...
end
Rubee::Configuration.setup(env = :production) do |config|
  config.database_url = { url: "postgres://postgres:#{ENV['DB_PASSWORD']}@localhost:5432/production", env: }
  ...
end
```

Before starting the server or running the test suite, ensure your database is initialized:
```bash
rubee db init                         # ensures your database is created for each environment
RACK_ENV=test rubee db run:all        # runs all migrations for the test environment
RACK_ENV=development rubee db run:all # runs all migrations for the development environment
```

[Back to content](#content)

### SQLite production ready

Starting from version 1.9.0, the main issue with SQLite — write database locking — is resolved.
You can tune the retry configuration parameters as needed:

```ruby
## configure database write retries
config.db_max_retries    = { env:, value: 3 }     # set to 0 to disable, or increase if needed
config.db_retry_delay    = { env:, value: 0.1 }
config.db_busy_timeout   = { env:, value: 1000 }  # busy timeout in milliseconds before raising an error
```

For ru.Bee model `create` and `update` methods, retries are added automatically. To use retries with a Sequel dataset directly:

```ruby
Rubee::DBTools.with_retry { User.dataset.insert(email: "test@ok.com", password: "123") }
```

[Back to content](#content)

## Routing

ru.Bee uses explicit routes. In `routes.rb` you can define routes for any of the main HTTP methods.
You can also include matched parameters denoted by `{ }` in the route path, e.g. `/path/to/{a_key}/somewhere`.

### Routing methods

```ruby
Rubee::Router.draw do |router|
  router.get     '/posts',       to: 'posts#index'
  router.post    '/posts',       to: 'posts#create'
  router.patch   '/posts/{id}',  to: 'posts#update'
  router.put     '/posts/{id}',  to: 'posts#update'
  router.delete  '/posts/{id}',  to: 'posts#delete'
  router.head    '/posts',       to: 'posts#index'
  router.connect '/posts',       to: 'posts#index'
  router.options '/posts',       to: 'posts#index'
  router.trace   '/posts',       to: 'posts#index'
end
```

Every route follows this structure:
```ruby
route.{http_method} {path}, to: "{controller}#{action}",
  model: { ...optional }, namespace: { ...optional }, react: { ...optional }
```

### Defining model attributes in routes

One of ru.Bee's unique traits is defining models for generation directly in the routes:

```ruby
Rubee::Router.draw do |router|
  ...
  router.get "/apples", to: "apples#index",
    model: {
      name: "apple",
      attributes: [
        { name: 'id', type: :primary },
        { name: 'colour', type: :string },
        { name: 'weight', type: :integer },
        { name: 'created', type: :datetime },
        { name: 'updated', type: :datetime },
      ]
    }
end
```

Other supported attribute types via Sequel:
```ruby
[
  { name: 'id',              type: :primary },
  { name: 'name',            type: :string },
  { name: 'description',     type: :text },
  { name: 'quantity',        type: :integer },
  { name: 'created',         type: :date },
  { name: 'modified',        type: :datetime },
  { name: 'exists',          type: :time },
  { name: 'active',          type: :boolean },
  { name: 'hash',            type: :bigint },
  { name: 'price',           type: :decimal },
  { name: 'item_id',         type: :foreign_key },
  { name: 'item_id_index',   type: :index },
  { name: 'item_id_unique',  type: :unique }
]
```

Every attribute can carry options based on the [Sequel schema definition](https://github.com/jeremyevans/sequel/blob/master/doc/schema_modification.rdoc). For example:

```ruby
{ name: 'key', type: :string, options: { size: 50, fixed: true } }
```

Gets translated to:
```ruby
String :key, size: 50, fixed: true
```

### Generation from routes

As long as a route has a `model:` key, you can use it to generate initial model files. If only `path` and `to:` are defined, only a controller and view will be generated.

```bash
rubee generate get /apples           # or: rubee gen get /apples
rubee generate patch /apples/{id}    # or: rubee gen patch /apples/{id}
```

**Example 1** — route without a model:
```ruby
router.get "/apples", to: "apples#index"
```
Generates:
```bash
./app/controllers/apples_controller.rb
./app/views/apples_index.erb
```

**Example 2** — route with a model name only:
```ruby
router.get "/apples", to: "apples#index", model: { name: 'apple' }
```
Generates:
```bash
./app/controllers/apples_controller.rb
./app/views/apples_index.erb
./app/models/apple.rb
./db/create_apples.rb
```

**Example 3** — route with full model attributes:
```ruby
router.get "/apples", to: "apples#index",
  model: {
    name: 'apple',
    attributes: [
      { name: 'id', type: :primary },
      { name: 'colour', type: :string },
      { name: 'weight', type: :integer },
      { name: 'created', type: :datetime },
      { name: 'updated', type: :datetime },
    ]
  }
```
Generates:
```bash
./app/controllers/apples_controller.rb
./app/models/apple.rb
./app/views/apples_index.erb
./db/create_apples.rb
```

### Modular application

ru.Bee supports modular applications — attach as many subprojects as you need. Each subproject gets its own folder, MVC setup, routes, and namespacing, while still sharing data with the main app.

1. Attach a new subproject
```bash
rubee attach admin
```

2. Add routes
```ruby
# admin_routes.rb
Rubee::Router.draw do |router|
  router.get '/admin/cabbages', to: 'cabbages#index',
                               model: {
                                 name: 'cabbage',
                                 attributes: [
                                   { name: 'id', type: :primary },
                                   { name: 'name', type: :string },
                                   { name: 'created', type: :datetime },
                                   { name: 'updated', type: :datetime },
                                 ]
                               },
                               namespace: :admin  # mandatory for namespacing support
end
```

3. Run the generate command
```bash
rubee gen get /admin/cabbages app:admin
```
Generates:
```bash
./admin/controllers/cabbages_controller.rb
./admin/views/cabbages_index.erb
./admin/models/cabbage.rb
./db/create_cabbages.rb
```

4. Run the migration
```bash
rubee db run:create_cabbages
```

5. Fill the controller with content
```ruby
# ./admin/controllers/cabbages_controller.rb
class Admin::CabbagesController < Rubee::BaseController
  def index
    response_with object: Cabbage.all, type: :json
  end
end
```

6. Run the server
```bash
rubee start  # or rubee start_dev for development
```

[Back to content](#content)

## Views

A view in ru.Bee is a plain HTML, ERB, or React file rendered from the controller.

### Templates with ERB

`layout.erb` is the parent template rendered first; child templates are rendered inside it. Feel free to include custom CSS and JS files there.

```ruby
# app/controllers/welcome_controller.rb

class WelcomeController < Rubee::BaseController
  def show
    response_with object: { message: 'Hello, world!' }
  end
end
```

```erb
<%# app/views/welcome_header.erb %>

<h1>All set up and running!</h1>
```

```erb
<%# app/views/welcome_show.erb %>

<div class="container">
    <%= render_template :welcome_header %> <%# attach an ERB partial with render_template %>
    <p><%= locals[:object][:message] %></p> <%# display the object passed from the controller %>
</div>
```

### React as a view

React is supported out of the box as a view layer in ru.Bee.

Prerequisites: Node and NPM are required.

1. After creating your project and bundling, install React dependencies:
```bash
rubee react prepare
```

2. Configure React in `config/base_configuration.rb`:
```ruby
Rubee::Configuration.setup(env = :development) do |config|
  config.database_url = { url: 'sqlite://db/development.db', env: }

  # register React as a view
  config.react = { on: true, env: }
end
```

3. Start the server:
```bash
rubee start
# Default port is 7000. To change it:
rubee start --port=3000
```

4. Open your browser and navigate to http://localhost:3000/home.

5. For development, run `rubee start_dev` in one terminal and `rubee react watch` in another. Changes apply instantly.

6. In production, rebuild the React app with `rubee react build`. Not needed in development when using `rubee react watch`.

7. Generate a React view from a route by specifying the view name:
```ruby
# config/routes.rb
Rubee::Router.draw do |router|
  router.get('/', to: 'welcome#show')

  router.get('/api/users', to: 'user#index', react: { view_name: 'users.tsx' })
  # Note: /api/users is the backend endpoint.
  # To render /app/views/users.tsx, update the React routes as shown below.
end
```

8. Add logic to the generated API controller:
```ruby
# app/controllers/api/user_controller.rb
class Api::UserController < Rubee::BaseController
  def index
    response_with object: User.all, type: :json
  end
end
```

9. Register the path in React routes:
```javascript
// app/views/app.tsx
<Router>
  <Routes>
    <Route path="/users" element={<Users />} />
    <Route path="*" element={<NotFound />} />
  </Routes>
</Router>
```

10. Fetch data from the backend in the component:
```javascript
// app/views/users.tsx
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

By including the `Hookable` module, any Ruby object can be charged with hooks — logic that executes before, after, or around a specific method call.

`BaseController` is Hookable by default:
```ruby
class ApplesController < Rubee::BaseController
  before :index, :print_hello                                       # use an instance method as a handler
  after  :index, -> { puts "after index" },  if:     -> { true }   # or use a lambda
  after  :index, -> { puts "after index2" }, unless: -> { false }  # if/unless guards accept a method or lambda
  around :index, :log

  def index
    response_with object: { test: "hooks" }
  end

  def print_hello
    puts "hello!"
  end

  def log
    puts "before log around"
    res = yield
    puts "after log around"
    res
  end
end
```

The server logs will show the following execution stack:
```bash
before log around
hello!
after index
after index2
after log around
127.0.0.1 - - [17/Feb/2025:11:42:14 -0500] "GET /apples HTTP/1.1" 401 - 0.0359
```

Starting from version 1.11, hooks can also be pinned to class methods:
```ruby
class AnyClass
  include Rubee::Hookable
  before :print_world, :print_hello, class_methods: true

  class << self
    def print_world
      puts "world!"
    end

    def print_hello
      puts "hello!"
    end
  end
end
```

Output:
```bash
hello!
world!
```

[Back to content](#content)

## Validations

Any class can be charged with validations by including the `Validatable` module.
ru.Bee models are validatable by default — no need to include it explicitly.

```ruby
class Foo
  include Rubee::Validatable

  attr_accessor :name, :age

  def initialize(name, age)
    @name = name
    @age = age
  end

  validate do
    attribute(:name).required.type(String).condition(->{ name.length > 2 })

    attribute(:age)
      .required('Age is a mandatory field')
      .type(Integer, error_message: 'Must be an integer!')
      .condition(->{ age > 18 }, fancy_error: 'You must be at least 18 years old!')
  end
end
```

```bash
irb(main):041> Foo.new("Test", 20).valid?
=> true
irb(main):042> Foo.new("Test", 1).errors
=> {age: {fancy_error: "You must be at least 18 years old!"}}
irb(main):046> Foo.new("Joe", "wrong").valid?
=> false
irb(main):047> Foo.new("Joe", "wrong").errors
=> {age: {error_message: "Must be an integer!"}}
```

Model example with persistence guards:
```ruby
class User < Rubee::SequelObject
  attr_accessor :id, :email, :password, :created

  validate_after_setters    # runs validation after each setter
  validate_before_persist!  # validates and raises an error if invalid before saving

  validate do
    attribute(:email).required
      .condition(
        ->{ email.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i) }, error: 'Wrong email format'
      )
  end
end
```

```bash
irb(main):077> user.save
=> {email: {error: "Wrong email format"}} (Rubee::Validatable::Error)
irb(main):078> user.email = "ok@ok.com"
irb(main):080> user.save
=> true
```

To apply `validate_before_persist!` and `validate_after_setters` globally, add an initializer such as `init/sequel_object_preloader.rb`:
```ruby
Rubee::SequelObject.validate_before_persist!
Rubee::SequelObject.validate_after_setters
```

[Back to content](#content)

## Rubee support

An optional set of useful methods can be added to base Ruby classes globally via configuration:

```ruby
# Include all support methods
Rubee::Configuration.setup do |config|
  config.rubee_support = { all: true }
end

# Include only methods for a specific class
Rubee::Configuration.setup do |config|
  config.rubee_support = { classes: [Rubee::Support::String] }
end
```

Available extensions:

```ruby
# Hash — tolerates string or symbol keys interchangeably
{one: 1}[:one]   # => 1
{one: 1}["one"]  # => 1

# Hash — deep digging
{one: {two: 2}}.deep_dig(:two)  # => 2
```

```ruby
# String — enriched with helper methods
"test".pluralize   # => "tests"
"test".singularize # => "test"
"test".camelize    # => "Test"
"TestMe".snakeize  # => "test_me"
"test".singular?   # => true
"test".plural?     # => false
```

[Back to content](#content)

## JWT based authentication

Include the `AuthTokenable` module in your controller and authenticate any action you need.

First, initialize the User model:
```bash
rubee db run:create_users
```

This creates the `users` table and seeds it with demo credentials — email `ok@ok.com`, password `password`. Customize `/db/create_users.rb` before running the migration if needed.

```ruby
class UsersController < Rubee::BaseController
  include Rubee::AuthTokenable
  auth_methods :index  # unauthenticated requests to these actions will be rejected

  # GET /users/login
  def edit
    response_with
  end

  # POST /users/login
  def login
    if authenticate!  # initializes @token_header
      response_with type: :redirect, to: "/users", headers: @token_header
    else
      @error = "Wrong email or password"
      response_with render_view: "users_edit"
    end
  end

  # POST /users/logout
  def logout
    unauthenticate!
    response_with type: :redirect, to: "/users/login", headers: @zeroed_token_header
  end

  # GET /users (restricted)
  def index
    response_with object: User.all, type: :json
  end
end
```

Set a `JWT_KEY` at startup for security:
```bash
JWT_KEY=SDJwer0wer23j rubee start
```

To use a custom model instead of the default `User`, pass arguments to `authenticate!` and `unauthenticate!`:
```ruby
if authenticate! user_model: Client, login: :name, password: :digest_password
  response_with type: :redirect, to: "/clients", headers: @token_header
end
```

[Back to content](#content)

## OAuth authentication

To plug in OAuth 2.0 authentication, add the `oauth2` gem to your Gemfile:
```bash
gem 'oauth2'
```

Use the following as a starting point:
```ruby
class UsersController < Rubee::BaseController
  include Rubee::AuthTokenable

  REDIRECT_URI  = 'https://mysite.com/users/oauth_callback'
  CLIENT_ID     = ENV['GOOGLE_CLIENT_ID']
  CLIENT_SECRET = ENV['GOOGLE_CLIENT_SECRET']

  # GET /login
  def edit
    response_with
  end

  # POST /users/login
  def login
    if authenticate!
      response_with(type: :redirect, to: "/sections", headers: @token_header)
    else
      @error = "Wrong email or password"
      response_with(render_view: "users_edit")
    end
  end

  # GET /users/oauth_login
  def oauth_login
    response_with(
      type: :redirect,
      to: auth_client.auth_code.authorize_url(
        redirect_uri: REDIRECT_URI,
        scope: 'email profile openid'
      )
    )
  end

  # GET /users/oauth_callback
  def oauth_callback
    code      = params[:code]
    token     = auth_client.auth_code.get_token(code, redirect_uri: REDIRECT_URI)
    user_info = JSON.parse(token.get('https://www.googleapis.com/oauth2/v1/userinfo?alt=json').body)

    user = User.where(email: user_info['email'])&.last
    raise "User with email #{user_info['email']} not found" unless user

    params[:email]    = user_info['email']
    params[:password] = user.password

    if authenticate!
      response_with(type: :redirect, to: "/sections", headers: @token_header)
    else
      @error = "Something went wrong"
      response_with(render_view: "users_edit")
    end
  rescue OAuth2::Error
    @error = "OAuth login failed"
    response_with(render_view: "users_edit")
  rescue StandardError
    @error = "Something went wrong"
    response_with(render_view: "users_edit")
  end

  # POST /users/logout
  def logout
    unauthenticate!
    response_with(type: :redirect, to: "/login", headers: @zeroed_token_header)
  end

  private

  def auth_client
    @client ||= OAuth2::Client.new(
      CLIENT_ID,
      CLIENT_SECRET,
      site:          'https://accounts.google.com',
      authorize_url: '/o/oauth2/auth',
      token_url:     'https://oauth2.googleapis.com/token'
    )
  end
end
```

[Back to content](#content)

## ru.Bee commands

```bash
rubee start          # start the server
rubee start_dev      # start the server in dev mode, restarting on file changes
rubee react prepare  # install React dependencies
rubee react watch    # React dev mode, use together with start_dev
rubee stop           # stop the server
rubee restart        # restart the server
```

## Generate commands

```bash
rubee generate get /apples  # generate controller, view, model, and migration if set in routes
rubee gen get /apples        # shorthand alias
```

## Migration commands

```bash
rubee db run:all              # run all migrations
rubee db run:create_apples    # run a specific migration file from /db
rubee db structure            # generate a migration file for the database structure
```

## Info commands

```bash
rubee routes             # print the routes table
rubee version            # print the current framework version
```

## ru.Bee console

```bash
rubee console  # start the interactive console
# type 'reload' inside the console to pick up the latest changes
```

To run any ru.Bee command in a specific environment, prefix with the env variable:
```bash
RACK_ENV=test rubee console
```

## Testing

```bash
rubee test                                          # run all tests
rubee test auth_tokenable_test.rb                   # run a specific test file
rubee test models/user_model_test.rb --line=12      # run a specific line
```

[Back to content](#content)

## Background jobs

There are currently two ways to integrate background jobs into your application:

- [Sidekiq](#sidekiq-engine)
- [ThreadAsync](#threadasync-engine)


## Sidekiq engine

The Sidekiq adapter allows you to process background jobs using Redis and the Sidekiq gem.

1. Add Sidekiq to your Gemfile

```ruby
gem 'sidekiq'
gem 'rack-session'  # Required for Sidekiq Web UI
```

2. Configure the adapter for the desired environment

```ruby
# config/base_configuration.rb
Rubee::Configuration.setup(env = :development) do |config|
  config.database_url  = { url: "sqlite://db/development.db", env: }
  config.async_adapter = { async_adapter: Rubee::SidekiqAsync, env: }
end
```

3. Install dependencies

```bash
bundle install
```

4. Start Redis - Redis must be running before starting Sidekiq

```bash
# Start Redis server
redis-server

# Or in background (macOS with Homebrew)
brew services start redis

# Verify Redis is running
redis-cli ping
# Should respond: PONG
```

5. Add Sidekiq configuration file

```yaml
# config/sidekiq.yml
:concurrency: 5
:queues:
  - default
  - mailers
  - critical
  - low

# Redis connection
:redis:
  url: redis://localhost:6379/0

# Optional: Logging
:verbose: false
:logfile: ./log/sidekiq.log

# Optional: PID file for daemon mode
:pidfile: ./tmp/pids/sidekiq.pid
```

6. Create Sidekiq boot file

```ruby
# inits/sidekiq.rb

# Configure Redis connection
Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }
end

# Load Rubee application context
unless Object.const_defined?('Rubee')
  require 'rubee'

  # Load environment variables
  require_relative 'dev.rb' if File.exist?(File.join(__dir__, 'dev.rb'))

  # Trigger Rubee autoload
  Rubee::Autoload.call
end
```

7. Create a Sidekiq worker

```ruby
# app/workers/test_async_runner.rb
class TestAsyncRunner
  include Rubee::Asyncable
  include Sidekiq::Worker

  sidekiq_options queue: :default, retry: 3

  def perform(options)
    options = parse_options(options)

    User.create(
      email: options['email'],
      password: options['password']
    )
  end

  private

  def parse_options(options)
    return options unless options.is_a?(String)

    begin
      JSON.parse(options)
    rescue JSON::ParserError
      options
    end
  end
end
```

8. Use it in your codebase

```ruby
# Enqueue job to run asynchronously
TestAsyncRunner.new.perform_async({
  "email" => "new@new.com",
  "password" => "123"
}.to_json)

# Schedule job to run in 5 minutes (300 seconds)
TestAsyncRunner.perform_in(300, {
  "email" => "new@new.com",
  "password" => "123"
})

```

### Running Sidekiq

Start Sidekiq in foreground mode for development:
```bash
bundle exec sidekiq -C config/sidekiq.yml -r ./inits/sidekiq.rb
```

Start Sidekiq as daemon in background:
```bash
# Start as daemon
bundle exec sidekiq -d -C config/sidekiq.yml -r ./inits/sidekiq.rb

# Stop daemon
kill -TERM $(cat tmp/pids/sidekiq.pid)

# View logs
tail -f log/sidekiq.log
```

Create helper scripts for convenience:
```bash
# bin/sidekiq_start
#!/bin/bash
bundle exec sidekiq -d \
  -C config/sidekiq.yml \
  -r ./inits/sidekiq.rb \
  -L log/sidekiq.log \
  -P tmp/pids/sidekiq.pid

echo "✓ Sidekiq started. PID: $(cat tmp/pids/sidekiq.pid)"
```

```bash
# bin/sidekiq_stop
#!/bin/bash
if [ -f tmp/pids/sidekiq.pid ]; then
  kill -TERM $(cat tmp/pids/sidekiq.pid)
  rm tmp/pids/sidekiq.pid
  echo "✓ Sidekiq stopped"
else
  echo "✗ Sidekiq is not running"
fi
```

Make them executable:
```bash
chmod +x bin/sidekiq_start bin/sidekiq_stop
```

### Sidekiq Web Dashboard

Create Sidekiq middleware for the web dashboard:

```ruby
# inits/middlewares/sidekiq_middleware.rb
require 'sidekiq/web'
require 'rack/session'

class SidekiqMiddleware
  def initialize(app)
    @app = app

    # Get or generate session secret
    session_secret = ENV.fetch('SESSION_SECRET') { generate_secret }

    # Build Sidekiq Web app with authentication
    @sidekiq_app = Rack::Builder.new do
      # Session support (required for CSRF protection)
      use Rack::Session::Cookie,
          secret: session_secret,
          same_site: true,
          max_age: 86400

      # Basic authentication
      use Rack::Auth::Basic, "Sidekiq Dashboard" do |username, password|
        username == ENV.fetch('SIDEKIQ_USERNAME', 'admin') &&
        password == ENV.fetch('SIDEKIQ_PASSWORD', 'password')
      end

      run Sidekiq::Web
    end
  end

  def call(env)
    if env['PATH_INFO'].start_with?('/sidekiq')
      # Route to Sidekiq Web UI
      env['SCRIPT_NAME'] = '/sidekiq'
      env['PATH_INFO'] = env['PATH_INFO'].sub(%r{^/sidekiq}, '') || '/'
      @sidekiq_app.call(env)
    else
      # Pass through to main app
      @app.call(env)
    end
  end

  private

  def generate_secret
    secret_file = '.session.key'

    if File.exist?(secret_file)
      File.read(secret_file).strip
    else
      require 'securerandom'
      secret = SecureRandom.hex(64)
      File.write(secret_file, secret)
      puts "Generated new session secret in #{secret_file}"
      secret
    end
  end
end
```

Set environment variables:
```bash
# .env
REDIS_URL=redis://localhost:6379/0
SIDEKIQ_USERNAME=admin
SIDEKIQ_PASSWORD=your_secure_password
SESSION_SECRET=generate_with_securerandom_hex_64
```

Generate SESSION_SECRET:
```bash
ruby -e "require 'securerandom'; puts SecureRandom.hex(64)"
```

Access the dashboard - Start your Rubee application and visit:
```
http://localhost:9292/sidekiq
```

Login with credentials from your `.env` file.

### Worker examples

Simple email worker:
```ruby
# app/workers/email_worker.rb
class EmailWorker
  include Rubee::Asyncable
  include Sidekiq::Worker

  sidekiq_options queue: :mailers, retry: 5

  def perform(options)
    options = parse_options(options)

    Mailer.send_email(
      to: options['email'],
      subject: options['subject'],
      body: options['body']
    )
  end

  private

  def parse_options(options)
    return options unless options.is_a?(String)
    JSON.parse(options) rescue options
  end
end

# Usage
EmailWorker.new.perform_async({
  "email" => "user@example.com",
  "subject" => "Welcome!",
  "body" => "Hello..."
}.to_json)
```

Worker with database records:
```ruby
# app/workers/booking_confirmation_worker.rb
class BookingConfirmationWorker
  include Rubee::Asyncable
  include Sidekiq::Worker

  sidekiq_options queue: :mailers, retry: 3

  def perform(options)
    options = parse_options(options)

    # Fetch records from database
    service = Service.find(options['service_id'])
    time_slot = TimeSlot.find(options['time_slot_id'])

    Mailer.booking_confirmation(
      to: options['to'],
      client_name: options['client_name'],
      service: service,
      time_slot: time_slot
    )
  end

  private

  def parse_options(options)
    return options unless options.is_a?(String)
    JSON.parse(options) rescue options
  end
end

# Usage
BookingConfirmationWorker.new.perform_async({
  "to" => "client@example.com",
  "client_name" => "John Doe",
  "service_id" => 15,
  "time_slot_id" => 91
})
```

### Queue priority

Configure queue processing priority in config/sidekiq.yml:

```yaml
:queues:
  - critical    # Processed first
  - default
  - mailers
  - low         # Processed last
```

Or with weights where higher weight means more frequently processed:

```yaml
:queues:
  - [critical, 7]
  - [default, 5]
  - [mailers, 3]
  - [low, 1]
```

### Monitoring and troubleshooting

Check Sidekiq status:
```bash
# View running processes
ps aux | grep sidekiq

# Check Redis connection
redis-cli ping

# View queue sizes
redis-cli LLEN queue:default
```

View logs:
```bash
# Tail Sidekiq logs
tail -f log/sidekiq.log

# View last 100 lines
tail -n 100 log/sidekiq.log
```

Common issues - Workers not processing: Ensure Redis is running with redis-cli ping. Check Sidekiq is started with ps aux | grep sidekiq. Verify queue names match in worker and config.

Common issues - Authentication errors on Web UI: Ensure rack-session gem is installed. Check SESSION_SECRET is at least 64 bytes. Verify SIDEKIQ_USERNAME and SIDEKIQ_PASSWORD are set.

Common issues - Jobs failing: Check log/sidekiq.log for errors. View failed jobs in Web UI at /sidekiq/retries. Verify environment variables are loaded in inits/sidekiq.rb.

### Best practices

Pass IDs not objects - Use booking.id instead of the booking object itself to avoid serialization issues.

Keep jobs small - Each job should do one thing and do it well.

Make jobs idempotent - Jobs should be safe to run multiple times with the same result.

Set appropriate retries - Use more retries for critical jobs and fewer for notifications.

Use different queues - Separate critical jobs from low-priority jobs using different queue names.

Handle JSON properly - Always parse options in the perform method to handle string arguments.

Monitor your queues - Use the Web UI to watch for backlogs and failed jobs.

Additional resources - Sidekiq Official Documentation at https://github.com/sidekiq/sidekiq/wiki. Best Practices guide at https://github.com/sidekiq/sidekiq/wiki/Best-Practices. Error Handling guide at https://github.com/sidekiq/sidekiq/wiki/Error-Handling.

[Back to content](#content)

### ThreadAsync engine

The default adapter is `ThreadAsync`. It is not yet recommended for production — use with caution.

1. Do not define any adapter in `config/base_configuration.rb`; the default `ThreadAsync` will be used.
2. Create a worker and process it:
```ruby
# test_async_runner.rb
class TestAsyncRunner
  include Rubee::Asyncable

  def perform(options)
    User.create(email: options['email'], password: options['password'])
  end
end

TestAsyncRunner.new.perform_async(options: { "email" => "new@new.com", "password" => "123" })
```

[Back to content](#content)

## Logger

Use your own logger by setting it in `config/base_configuration.rb`:
```ruby
Rubee::Configuration.setup(env = :development) do |config|
  config.database_url = { url: "sqlite://db/development.db", env: }
  config.logger       = { logger: MyLogger, env: }
end
```

Or use the built-in logger with its full set of levels:
```ruby
# app/controllers/welcome_controller.rb
class WelcomeController < Rubee::BaseController
  around :show, ->(&target_method) do
    start = Time.now
    Rubee::Logger.warn(message: 'This is a warning message', method: :show, class_name: 'WelcomeController')
    Rubee::Logger.error(message: 'This is an error message', class_name: 'WelcomeController')
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

Output:
```bash
[2025-04-26 12:32:33] WARN     [method: show][class_name: WelcomeController] This is a warning message
[2025-04-26 12:32:33] ERROR    [class_name: WelcomeController] This is an error message
[2025-04-26 12:32:33] CRITICAL We are on fire!
[2025-04-26 12:32:33] INFO     [method: show][class_name: WelcomeController] Execution Time: 0.000655 seconds
[2025-04-26 12:32:33] DEBUG    [method: show][class_name: WelcomeController] #<User:0x000000012c5c63e0 ...>
```

[Back to content](#content)

## WebSocket

With ru.Bee 2.0.0 you can use WebSocket with ease.

1. Install and start Redis
```bash
sudo apt-get install -y redis  # Linux
brew install redis              # macOS
```

2. Add the required gems to your Gemfile
```ruby
gem 'ru.Bee'
gem 'redis'
gem 'websocket'
```

3. Add the Redis URL to your configuration, unless it defaults to `127.0.0.1:6379`
```ruby
# config/base_configuration.rb
Rubee::Configuration.setup(env = :development) do |config|
  ...
  config.redis_url = { url: "redis://localhost:6378/0", env: }
end
```

4. Add a WebSocket entry route
```ruby
# config/routes.rb
Rubee::Router.draw do |router|
  ...
  router.get('/ws', to: 'users#websocket')
  # On the client: const ws = new WebSocket("ws://website/ws");
end
```

5. Make the model pub/sub capable
```ruby
# app/models/user.rb
class User < Rubee::BaseModel
  include Rubee::PubSub::Publisher
  include Rubee::PubSub::Subscriber
  ...
end
```

6. Enable WebSocket in your controller and implement the required methods
```ruby
# app/controllers/users_controller.rb
class UsersController < Rubee::BaseController
  attach_websocket!  # handles WebSocket connections and routes them to publish, subscribe, unsubscribe

  # Expected client params: { action: 'subscribe', channel: 'default', id: '123', subscriber: 'User' }
  def subscribe
    channel   = params[:channel]
    sender_id = params[:options][:id]
    io        = params[:options][:io]

    User.sub(channel, sender_id, io) do |channel, args|
      websocket_connections.register(channel, args[:io])
    end
    response_with(object: { type: 'system', channel: params[:channel], status: :subscribed }, type: :websocket)
  rescue StandardError => e
    response_with(object: { type: 'system', error: e.message }, type: :websocket)
  end

  # Expected client params: { action: 'unsubscribe', channel: 'default', id: '123', subscriber: 'User' }
  def unsubscribe
    channel   = params[:channel]
    sender_id = params[:options][:id]
    io        = params[:options][:io]

    User.unsub(channel, sender_id, io) do |channel, args|
      websocket_connections.remove(channel, args[:io])
    end
    response_with(object: params.merge(type: 'system', status: :unsubscribed), type: :websocket)
  rescue StandardError => e
    response_with(object: { type: 'system', error: e.message }, type: :websocket)
  end

  # Expected client params: { action: 'publish', channel: 'default', message: 'Hello', id: '123', subscriber: 'User' }
  def publish
    args = {}
    User.pub(params[:channel], message: params[:message]) do |channel|
      user               = User.find(params[:options][:id])
      args[:message]     = params[:message]
      args[:sender]      = params[:options][:id]
      args[:sender_name] = user.email
      websocket_connections.stream(channel, args)
    end
    response_with(object: { type: 'system', message: params[:message], status: :published }, type: :websocket)
  rescue StandardError => e
    response_with(object: { type: 'system', error: e.message }, type: :websocket)
  end
end
```

For a full chat application example, see [rubee-chat](https://github.com/nucleom42/rubee-chat).

[Back to content](#content)

## Bee assistant

ru.Bee ships with a built-in CLI assistant called `bee`. It answers questions about the framework directly in your terminal, using a local TF-IDF knowledge base built from the project documentation. Optionally, it routes answers through a local Ollama language model for richer, more conversational responses.

No external API keys or internet connection are required in the default mode.

### Building the knowledge base

Before using the assistant for the first time, generate the knowledge base from the README:

```bash
rubee bee generate  # or: rubee bee gen
```

This parses the documentation, computes TF-IDF vectors, and writes a `bee_knowledge.json` file to `lib/rubee/cli/`. Re-run this command any time the documentation is updated.

### Interactive mode

Start an interactive session and ask questions conversationally:

```bash
rubee bee
```

```
  ⬡ ⬢ ⬢  ru.Bee — domestic AI assistant
  ──────────────────────────────────────────────
  Ask me anything about the ru.Bee framework.
  Type exit to leave  •  rubee bee generate to retrain.
  You: How do I run the server?
```

Type `exit`, `quit`, `bye`, or `q` to leave the session.

### Single-shot mode

Pass a question directly as a command-line argument to get one answer and exit:

```bash
rubee bee how do hooks work
rubee bee what databases are supported
rubee bee how do I set up JWT authentication
```

### LLM mode

If you have [Ollama](https://ollama.com) installed and running locally, enable LLM mode for more detailed answers. The assistant retrieves the most relevant documentation and passes it as context to the model.

```bash
rubee bee --llm                        # interactive mode, default model (qwen2.5:1.5b)
rubee bee --llm=llama3.2               # interactive mode, specific model
rubee bee --llm how do hooks work      # single-shot LLM answer
rubee bee --llm=qwen2.5:0.5b how do I configure WebSocket  # single-shot with specific model
```

If the specified model is not available locally, the assistant automatically pulls it from Ollama before answering, displaying a live download progress bar.

### Environment options

```bash
OLLAMA_URL=http://remote-host:11434 rubee bee --llm  # use a custom Ollama endpoint
BEE_KNOWLEDGE=/path/to/custom.json rubee bee         # use a custom knowledge base file
BEE_DEBUG=1 rubee bee --llm                          # write LLM debug output to /tmp/bee_ollama_debug.txt
```

### Suggestions

After every answer, the assistant suggests up to five related topics you might want to explore next, along with a link to the full documentation at https://rubee.dedyn.io/.

### Command reference

```bash
rubee bee generate                      # build the knowledge base from the README
rubee bee gen                           # alias for generate
rubee bee                               # start interactive mode
rubee bee <question>                    # single-shot answer
rubee bee --llm                         # interactive LLM mode (default model: qwen2.5:1.5b)
rubee bee --llm=<model>                 # interactive LLM mode with a specific Ollama model
rubee bee --llm <question>              # single-shot LLM answer
rubee bee --llm=<model> <question>      # single-shot with a specific model
```

[Back to content](#content)

### Contributing

If you are interested in contributing to ru.Bee, please read the [Contributing](https://github.com/nucleom42/rubee/blob/main/contribution.md) guide.
Feel free to open an [issue](https://github.com/nucleom42/rubee/issues) if you spot one.
Have an idea or want to discuss something? Open a [discussion](https://github.com/nucleom42/rubee/discussions).

## Middleware integration

ru.Bee is rack based framework, so you can use register and use middleware for your application.
1. Create a middleware
```ruby
# app/inits/middlewares/my_middleware.rb
class MyMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    Logger.info("Middleware called")
    @app.call(env)
  end
end
```
2. Register the middleware in the `config/base_configuration.rb`
```ruby
# config/base_configuration.rb
require_relative 'inits/middlewares/my_middleware'

config.middlewares = { middlewares: [MyMiddleware], env: }
```

## Roadmap

Please refer to the [Roadmap](https://github.com/nucleom42/rubee/blob/main/roadmap.md).

## License

This project is released under the [MIT License](https://github.com/nucleom42/rubee/blob/main/LICENSE).
