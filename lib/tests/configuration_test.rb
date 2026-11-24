require_relative 'test_helper'

describe 'Configuration' do
  describe 'rubee_support Hash only' do
    it 'patches Hash only' do
       String.send(:undef_method, :plural?) if "".respond_to?(:plural?)
      Rubee::Configuration.setup(env = :test) do
        _1.rubee_support = { classes: [Rubee::Support::Hash] }
      end
      _({ one: 1 }['one']).must_equal(1)

      _(raise_error { "apples".plural? }.is_a?(NoMethodError)).must_equal(true)
    end
  end

  describe 'rubee_support all' do
    it 'patches Hash and String' do
      Rubee::Configuration.setup(env = :test) { _1.rubee_support = { all: true } }
      _({ one: 1 }['one']).must_equal(1)
      _("apples".plural?).must_equal(true)
    end
  end

  describe 'when ENV["RACK_ENV"] eq test' do
    it 'laods env var to ENV' do
      _(ENV['RACK_ENV']).must_equal('test')
      _(ENV['SUPER_PASSWORD']).must_equal('test_password')
    end
  end

  describe 'auth' do
    it 'falls back to AuthTokenable defaults when not configured' do
      _(Rubee::AuthTokenable.key).must_equal(Rubee::AuthTokenable::KEY)
      _(Rubee::AuthTokenable.expire).must_equal(Rubee::AuthTokenable::EXPIRE)
      _(Rubee::AuthTokenable.refresh_expire).must_equal(Rubee::AuthTokenable::REFRESH_EXPIRE)
      _(Rubee::AuthTokenable.refresh_cookie).must_equal(Rubee::AuthTokenable::REFRESH_COOKIE)
      _(Rubee::AuthTokenable.refresh_salt).must_equal(Rubee::AuthTokenable::REFRESH_SALT)
    end

    it 'allows overriding auth settings per env' do
      original = Rubee::Configuration.auth.dup
      begin
        Rubee::Configuration.setup(env = :test) do |config|
          config.auth = {
            key: 'custom-key',
            expire: 60,
            refresh_expire: 120,
            refresh_cookie: 'custom_refresh',
            refresh_salt: 'custom_salt',
            env:,
          }
        end

        _(Rubee::AuthTokenable.key).must_equal('custom-key')
        _(Rubee::AuthTokenable.expire).must_equal(60)
        _(Rubee::AuthTokenable.refresh_expire).must_equal(120)
        _(Rubee::AuthTokenable.refresh_cookie).must_equal('custom_refresh')
        _(Rubee::AuthTokenable.refresh_salt).must_equal('custom_salt')
      ensure
        Rubee::Configuration.setup(env = :test) do |config|
          config.auth = original.merge(env:)
        end
      end
    end
  end
end
