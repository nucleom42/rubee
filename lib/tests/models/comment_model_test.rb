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
end
