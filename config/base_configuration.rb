Rubee::Configuration.setup(env=:development) do |config|
  config.database_url = { url: "db/development.sqlite3", env: }
end

Rubee::Configuration.setup(env=:test) do |config|
  config.database_url = { url: "db/test.sqlite3", env: }
end

Rubee::Configuration.setup(env=:production) do |config|
  config.database_url = { url: "db/production.sqlite3", env: }
end
