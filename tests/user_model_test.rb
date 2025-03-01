require_relative 'test_helper'

describe 'User model' do
  describe ".create" do
    it 'persists to db' do
      user = User.create(email: "ok-test@test.com", password: "123")

       _(user.persisted?).must_equal true
    end
  end
end
