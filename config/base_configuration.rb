Rubee::Configuration.setup(env=:development) do |config|
  config.database_url = { url: "sqlite://db/development.db", env: }
  config.async_adapter = { async_adapter: ThreadAsync, env: }
end

Rubee::Configuration.setup(env=:test) do |config|
  config.database_url = { url: "sqlite://db/test.db", env: }
  config.async_adapter = { async_adapter: ThreadAsync, env: }
end

Rubee::Configuration.setup(env=:production) do |config|
  config.database_url = { url: "sqlite://db/production.db", env: }
  config.async_adapter = { async_adapter: ThreadAsync, env: }
end
