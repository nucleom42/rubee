require_relative '../test_helper'

describe 'When sequle raise error' do
  it 'should save error' do
    apple = Apple.new(updated: Time.now)
    apple.save
    _(apple.errors).must_equal(
      { base: { sequel_error: "SQLite3::ConstraintException: NOT NULL constraint failed: apples.color" } }
    )
  end
end
