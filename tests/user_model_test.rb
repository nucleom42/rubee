require_relative 'test_helper'

describe 'User model' do
  before do
    @user = User.new(email: 'test@test.com', password: 'password')
  end

  it 'persists to db' do
    @user.save
    assert_equal User.where(email: 'test@test.com').last.nil?, false
  end
end
