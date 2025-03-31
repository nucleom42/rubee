require_relative 'test_helper'

describe 'Comment model' do
  describe 'owns_many :users, over: :posts' do
    after do
      Comment.destroy_all cascade: true
    end

    describe 'when there are associated comment records' do
      it 'returns all records' do
        comment = Comment.new(content: "test")
        comment.save
        user = User.new(email: "ok-test@test.com", password: "123")
        user.save
        post = Post.new(user_id: user.id, comment_id: comment.id)
        post.save
        _(comment.users.count).must_equal 1
        _(comment.users.first.email).must_equal user.email
      end
    end
  end
end
