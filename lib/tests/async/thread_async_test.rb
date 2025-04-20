require_relative '../test_helper'

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
        TestAsyncRunnner.new.perform_async(options: {"email"=> "new#{n}@new.com", "password"=> "123"})
      end
    end

    it 'creates 5 users' do
      assert_difference(-> { User.count }, 5) { subject }
    end

    it 'does it async' do
      # TODO
    end
  end
end
