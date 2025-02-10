# Rubee

<p align="left">
  <img src="images/rubee.svg" alt="Rubee" height="50">
</p>

Rubee is a fast and lightweight Ruby application server designed for minimalism and high performance.

The main pholosophy of Rubee is to focus on Ruby language explicit implementation of  the MVC web applications.
There are no hidden details, you can adjust it for your needs.

All greaet features are yet to come!

## Features

- **Lightweight**: A minimal footprint that focuses on serving Ruby applications efficiently.
- **Fast**: Optimized for speed, providing a quick response to requests.
- **Rack**: Rrack backed
- **Router**: Router driven
- **Databases**: sqlite3
- **Views**: Json, ERB

## Installation

1. Create your project directory
```bash
mkdir my_project
cd my_project
```

2. Clone the rubee repository
```bash
gh repo clone nucleom42/rubee .
```

3. Install dependencies
```bash
bundle install
```

4. Run rubee server. Default port is 7000
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
      attributes: [ { name: 'colour', type: :string }, { name: 'weight', type: :integer } ]
    }
end
```
2. genrate the files
```bash
./com/generate get /apples
```
3. This will generate the following files
```bash
./app/controllers/apples_controller.rb # controller
./app/models/apple.rb # model
./app/views/apples_index.erb # view that is rendered by the controller right away
.db/create_items.rb # database migration
```
4. Fill those file with the logic you need and run the server again!

