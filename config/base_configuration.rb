Rubee::Configuration.setup(env=:development) do |config|
  config.database_url = { url: "sqlite://db/development.db", env: }
end

Rubee::Configuration.setup(env=:test) do |config|
  config.database_url = { url: "sqlite://db/test.db", env: }
end

Rubee::Configuration.setup(env=:production) do |config|
  config.database_url = { url: "sqlite://db/production.db", env: }
end
