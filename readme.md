# RuBee

<p align="left">
  <img src="images/rubee.svg" alt="Rubee" height="50">
</p>

RuBee is a fast and lightweight Ruby application server designed for minimalism and flexibility .

The main philosophy of RuBee is to focus on Ruby language explicit implementation of the MVC web application.
There are no hidden details, you can adjust it for your needs.

Want to get a quick API server up and runing? You can do it for less than 7 min!
[![Demo Video](http://img.youtube.com/vi/Udz476rI0gs/0.jpg)](http://www.youtube.com/watch?v=Udz476rI0gs "RuBee API demo")
My typing is bad, I probably could do it in 5 min.

All greaet features are yet to come!

## Features

- **Lightweight**: A minimal footprint that focuses on serving Ruby applications efficiently.
- **Contract driven**: Define your API contracts in a simple, declarative manner. And generate the files for you.
- **Fast**: Optimized for speed, providing a quick response to requests. Everything is relative, I know!
- **Rack**: Rack backed. All Rack api is available for integration.
- **Router**: Router driven - generates all required files from the routes.
- **Databases**: Sqlite3
- **Views**: Json, ERB
- **Bundlable** Charge your RuBee with any gem you need and update your project with bundle

## Installation

1. Create your project directory
```bash
mkdir my_project
cd my_project
```

2. Clone the rubee repository
```bash
git clone https://github.com/nucleom42/rubee .
```

3. Install dependencies

***Prerequisites***<br />
**RuBee** is using **Sqlite** as a default database. Please make sure you get it installed.
Aside that, make sure:
**Ruby** language (3+) is installed
**Bundler** is installed

```bash
bundle install
```

4. Run RuBee server. Default port is 7000
```bash
./com/rubee start
```

## Generating files from the routes
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
./com/generate get /apples
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
Model in RuBee is just simple ruby object that can be serilalized in the view
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
    attr_accessor :colour, :weight
  end
```
However, you can simply turn it to ORM object by extending database class.

```Ruby
  class Apple < SqliteObject
    attr_accessor :colour, :weight
  end
```

So in the controller you would need to query your target object

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

## Object hooks

In RuBee by extending Hookable module any Ruby objcet can be charged with hooks (logic),
that can be executed before, after and around a specific method execution.

Here below a controller example. However it can be used in any Ruby object, like Model etc.
```ruby
# base conrteoller is hopokable by Default
class ApplesController < BaseController
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
## TODOs
- [ ] Token authorization API
- [ ] Add test coverage
- [ ] Fix bugs
