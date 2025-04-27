Rubee::Configuration.setup(env = :development) do |config|
  config.database_url = { url: 'sqlite://db/development.db', env: }

  ## configure hybrid thread pooling params
  # config.threads_limit = { env:, value: 4 }
  # config.fibers_limit = { env:, value: 4 }

  # Flag on react as a view
  # config.react = { on: true, env: } # required if you want to use react

  ## configure logger
  # config.logger = { logger: MyLogger, env: }
end

Rubee::Configuration.setup(env = :test) do |config|
  config.database_url = { url: 'sqlite://db/test.db', env: }

  ## configure hybrid thread pooling params
  # config.threads_limit = { env:, value: 4 }
  # config.fibers_limit = { env:, value: 4 }

  ## Flag on react as a view
  # config.react = { on: true, env: } # required if you want to use react

  ## configure logger
  # config.logger = { logger: MyLogger, env: }
end

Rubee::Configuration.setup(env = :production) do |config|
  config.database_url = { url: 'sqlite://db/production.db', env: }

  ## configure hybrid thread pooling params
  # config.threads_limit = { env:, value: 4 }
  # config.fibers_limit = { env:, value: 4 }

  ## Flag on react as a view
  # config.react = { on: true, env: } # required if you want to use react

  ## configure logger
  # config.logger = { logger: MyLogger, env: }
end
