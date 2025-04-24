require_relative '../test_helper'

describe 'Account model' do
  describe 'holds :user' do
    after do
      Account.destroy_all(cascade: true)
    end

    describe 'when it holds user_id' do
      it 'returns associated User record' do
        user = User.new(email: 'ok-test@test.com', password: '123')
        user.save
        account = Account.new(user_id: user.id, addres: 'test')
        account.save
        _(account.user.id).must_equal(user.id)
      end
    end
  end
end
