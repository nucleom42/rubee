require_relative '../test_helper'

require 'timeout'

class TestAsyncRunnner
  include Rubee::Asyncable

  def perform(options)
    User.create(email: options['email'], password: options['password'])
  end
end

describe 'TestAsyncRunnner' do
  describe 'async' do
    after do
      Rubee::ThreadPool.instance.shutdown
      User.destroy_all
    end

    subject do
      5.times do |n|
        TestAsyncRunnner.new.perform_async(options: { "email" => "new#{n}@new.com", "password" => "123" })
      end
    end

    it 'creates 5 users' do
      subject

      Timeout.timeout(1) do
        sleep(0.1) until User.count == 5
      end

      assert_equal 5, User.count
    end
  end
end
