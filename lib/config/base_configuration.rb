Rubee::Configuration.setup(env = :development) do |config|
  config.database_url = { url: 'sqlite://db/development.db', env: }
  config.react = { on: true, env: } # required if you want to use react
end

Rubee::Configuration.setup(env = :test) do |config|
  config.database_url = { url: 'sqlite://db/test.db', env: }
  config.react = { on: true, env: } # required if you want to use react
end

Rubee::Configuration.setup(env = :production) do |config|
  config.database_url = { url: 'sqlite://db/production.db', env: }
  config.react = { on: true, env: } # required if you want to use react
end
