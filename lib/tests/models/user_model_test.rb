require_relative '../test_helper'
describe 'User model' do
  describe '.create' do
    after do
      User.destroy_all(cascade: true)
    end

    describe 'when data is valid' do
      it 'persists to db' do
        user = User.create(email: 'ok-test@test.com', password: '123')

        _(user.persisted?).must_equal(true)
      end
    end

    describe 'when data is invalid' do
      it 'is not changing users number' do
        initial_count = User.all.count
        begin
          User.create(wrong: 'test@test')
        rescue StandardError
          nil
        end

        _(User.all.count).must_equal(initial_count)
      end
    end
  end

  describe '.save' do
    after do
      User.destroy_all(cascade: true)
    end

    describe 'when data is valid' do
      it 'persists to db' do
        user = User.new(email: 'ok-test@test.com', password: '123')
        user.save

        _(user.persisted?).must_equal(true)
      end
    end

    describe 'when save existing user' do
      it 'persists to db' do
        user = User.new(email: 'ok-test@test.com', password: '123')
        user.save

        _(user.reload.password).must_equal('123')
      end
    end

    describe 'when data is invalid' do
      it 'is not changing users number' do
        initial_count = User.all.count
        user = begin
          User.new(wrong: 'test@test')
               rescue StandardError
                 nil
        end
        begin
          user.save
        rescue StandardError
          nil
        end

        _(User.all.count).must_equal(initial_count)
      end
    end

    describe 'locking model' do
      before do
        User.destroy_all(cascade: true)
      end

      it 'triggers save two times' do
        t1 = Thread.new do
          User::DB.transaction do
            user2 = User.new(email: 'holding-lock2@example.com', password: '125')
            sleep(0.5)
            user2.save
          end
        end
        sleep(0.1)
        t2 = Thread.new do
          user1 = User.new(email: 'holding-lock@example.com', password: '123')
          user1.save
        end

        t1.join
        t2.join

        _(User.all.count).must_equal(2)
      end
    end
  end

  describe '.update' do
    after do
      User.destroy_all(cascade: true)
    end

    describe 'when data is valid' do
      it 'persists to db' do
        user = User.new(email: 'ok-test@test.com', password: '123')
        user.save
        user.update(password: '1234')

        _(user.reload.password).must_equal('1234')
      end
    end
  end

  describe '.destroy' do
    after do
      User.destroy_all(cascade: true)
    end

    describe 'when there is no related recrods' do
      it 'delete the record' do
        user = User.new(email: 'ok-test@test.com', password: '123')
        user.save
        user.destroy

        assert_nil user.reload
      end
    end

    describe 'when there are related recrods' do
      it 'does not delete the record' do
        user = User.new(email: 'ok-test@test.com', password: '123')
        user.save
        Account.new(user_id: user.id, addres: 'test').save
        begin
          user.destroy
        rescue StandardError
          nil
        end

        _(user.reload.id).must_equal(user.id)
      end
    end

    describe 'when there are related recrods but passed cascade=true' do
      it 'deletes the record' do
        user = User.new(email: 'ok-test@test.com', password: '123')
        user.save
        Account.new(user_id: user.id, addres: 'test').save
        user.destroy(cascade: true)

        assert_nil user.reload
      end
    end
  end

  describe '.find' do
    after do
      User.destroy_all(cascade: true)
    end

    describe 'when trhere is a record' do
      it 'returns a record' do
        user = User.new(email: 'ok-test@test.com', password: '123')
        user.save
        _(User.find(user.id).email).must_equal(user.email)
      end
    end

    describe 'when there is no record' do
      it 'returns nil' do
        assert_nil User.find(1)
      end
    end
  end

  describe '.all' do
    after do
      User.destroy_all(cascade: true)
    end

    before do
      User.destroy_all(cascade: true)
    end

    describe 'when there are records' do
      it 'returns all records' do
        # skip "This is Flaky test that blcoks dev, need to be fixed"
        user = User.new(email: 'ok-test@test.com', password: '123')
        user2 = User.new(email: 'ok-test2@test.com', password: '123')
        user.save
        user2.save
        _(User.all.count).must_equal(2)
      end
    end
  end

  describe '.where' do
    after do
      User.destroy_all(cascade: true)
    end

    describe 'when there are records' do
      it 'returns all records' do
        user = User.new(email: 'ok-test@test.com', password: '123')
        user2 = User.new(email: 'ok-test2@test.com', password: '123')
        user.save
        user2.save
        _(User.where(email: 'ok-test2@test.com').count).must_equal(1)
      end
    end
  end

  describe '.first' do
    after do
      User.destroy_all(cascade: true)
    end

    describe 'when there are records' do
      it 'returns first record' do
        user = User.new(email: 'ok-test@test.com', password: '123')
        user2 = User.new(email: 'ok-test2@test.com', password: '123')
        user.save
        user2.save
        _(User.first.email).must_equal(user.email)
      end
    end
  end

  describe '.last' do
    after do
      User.destroy_all(cascade: true)
    end

    describe 'when there are records' do
      it 'returns last record' do
        user = User.new(email: 'ok-test@test.com', password: '123')
        user2 = User.new(email: 'ok-test2@test.com', password: '123')
        user.save
        user2.save
        _(User.last.email).must_equal(user2.email)
      end
    end
  end

  describe '.order' do
    after do
      User.destroy_all(cascade: true)
    end

    describe 'when there are records' do
      it 'returns ordered records' do
        user = User.new(email: 'abc@test.com', password: '123')
        user2 = User.new(email: 'defg@test.com', password: '123')
        user.save
        user2.save
        _(User.order(:email).first.email).must_equal(user.email)
      end
    end
  end

  describe 'owns_many' do
    after do
      User.destroy_all(cascade: true)
    end

    describe 'when there are associated account records' do
      it 'returns all records' do
        user = User.new(email: 'ok-test@test.com', password: '123')
        user.save
        account = Account.new(user_id: user.id, addres: 'test')
        account.save
        _(user.accounts.count).must_equal(1)
      end
    end
  end

  describe 'owns_one' do
    after do
      User.destroy_all(cascade: true)
    end
    describe 'when there is one associated account' do
      it 'cannot add more than one address' do
        skip "This is an idea that can be implemented later"
        user = User.new(email: 'bleh@example.com', password: '123')
        user.save

        address = Address.new(user_id: user.id, street: '1234 ble ave', apt: '', city: 'NY', state: 'NY', zip: '555555')
        address.save

        address_two = Address.new(user_id: user.id, street: '1234 ble ave', apt: '', city: 'NY', state: 'NY',
zip: '555555')

        _ { address_two.save }.must_raise(Rubee::OwnsOneError)
      end

      it 'returns the single address' do
        user = User.new(email: 'bleh@example.com', password: '123')
        user.save

        address = Address.new(user_id: user.id, street: '1234 ble ave', apt: '', city: 'NY', state: 'NY', zip: '555555')
        address.save

        _(user.address.id).must_equal(address.id)
      end
    end
  end
end
