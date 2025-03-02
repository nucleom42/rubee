Rubee::Configuration.setup(env=:development) do |config|
  config.database_url = { url: "postgres://postgres:postgres@localhost:5432/development", env: }
end

Rubee::Configuration.setup(env=:test) do |config|
  config.database_url = { url: "postgres://postgres:postgres@localhost:5432/test", env: }
end

Rubee::Configuration.setup(env=:production) do |config|
  config.database_url = { url: "postgres://postgres:postgres@localhost:5432/production", env: }
end
