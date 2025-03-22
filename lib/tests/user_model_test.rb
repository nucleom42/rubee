require_relative 'test_helper'

describe 'User model' do
  describe ".create" do
    after do
      User.destroy_all
    end

    describe 'when data is valid' do
      it 'persists to db' do
        user = User.create(email: "ok-test@test.com", password: "123")

         _(user.persisted?).must_equal true
      end
    end

    describe 'when data is invalid' do
      it 'is not changing users number' do
        initial_count = User.all.count
        User.create(wrong: "test@test") rescue nil

        _(User.all.count).must_equal initial_count
      end
    end
  end

  describe '.save' do
    after do
      User.destroy_all
    end

    describe 'when data is valid' do
      it 'persists to db' do
        user = User.new(email: "ok-test@test.com", password: "123")
        user.save

        _(user.persisted?).must_equal true
      end
    end

    describe 'when save existing user' do
      it 'persists to db' do
        user = User.new(email: "ok-test@test.com", password: "123")
        user.save

        _(user.reload.password).must_equal "123"
      end
    end

    describe 'when data is invalid' do
      it 'is not changing users number' do
        initial_count = User.all.count
        user = User.new(wrong: "test@test") rescue nil
        user.save rescue nil

        _(User.all.count).must_equal initial_count
      end
    end
  end
end
