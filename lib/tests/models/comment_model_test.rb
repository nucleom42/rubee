require_relative '../test_helper'

describe 'Comment model' do
  describe 'owns_many :users, over: :posts' do
    before do
      comment = Comment.new(text: 'test')
      comment.save
      user = User.new(email: 'ok-test@test.com', password: '123')
      user.save
      post = Post.new(user_id: user.id, comment_id: comment.id)
      post.save
    end

    after do
      Comment.destroy_all(cascade: true)
    end

    describe 'when there are associated comment records' do
      it 'returns all records' do
        _(Comment.where(text: 'test').last.users.count).must_equal(1)
        _(Comment.where(text: 'test').last.users.first.email).must_equal('ok-test@test.com')
      end
    end

    describe 'sequel dataset query' do
      it 'returns all records' do
        result = Comment.dataset.join(:posts, comment_id: :id)
          .where(comment_id: Comment.where(text: 'test').last.id)
          .then { |dataset| Comment.serialize(dataset) }

        _(result.first.text).must_equal('test')
      end
    end
  end

  describe 'method' do
    it 'updates existing model' do
      comment = Comment.new(text: 'test 1')
      comment.save

      comment.text = 'test 2'
      comment.save

      _(Comment.find(comment.id).text).must_equal('test 2')
    end
  end

  describe 'validatable' do
    def include_and_validate
      Comment.include(Rubee::Validatable)
      Comment.validate do |comment|
        comment
          .required(:text, required: "text filed is required")
          .type(String, type: "text field must be string")
          .condition(-> { comment.text.length > 4 }, { length: "text length must be greater than 4" })
      end
    end
    it 'is valid' do
      include_and_validate
      comment = Comment.new(text: 'test it as valid')

      _(comment.valid?).must_equal(true)
    end

    it 'is not valid length' do
      include_and_validate
      comment = Comment.new(text: 'test')

      _(comment.valid?).must_equal(false)
      _(comment.errors[:text]).must_equal({ length: "text length must be greater than 4" })
    end

    it 'is not valid type' do
      include_and_validate
      comment = Comment.new(text: 1)

      _(comment.valid?).must_equal(false)
      _(comment.errors[:text]).must_equal({ type: "text field must be string" })
    end

    it 'is not valid required' do
      include_and_validate
      comment = Comment.new(user_id: 1)

      _(comment.valid?).must_equal(false)
      _(comment.errors[:text]).must_equal({ required: "text filed is required" })
    end
  end
end
