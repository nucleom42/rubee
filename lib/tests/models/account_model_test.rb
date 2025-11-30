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

    describe '#validate_before_persist' do
      it 'rasies error if account is not valid' do
        Account.validate do
          required(:addres, required: "address is required")
            .type(String, type: "address must be string")
        end
        Account.validate_before_persist!
        user = User.new(email: 'ok-test@test.com', password: '123')
        _(raise_error { Account.create(addres: 1, user_id: user.id) }.is_a?(Rubee::Validatable::Error)).must_equal(true)
        account = Account.create(addres: "13Th street", user_id: user.id)
        _(account.persisted?).must_equal(true)
        _(raise_error { account.update(addres: 1) }.is_a?(Rubee::Validatable::Error)).must_equal(true)
        _(raise_error { Account.new(addres: 1, user_id: user.id).save }.is_a?(Rubee::Validatable::Error)).must_equal(true)
      end
    end
  end
end
