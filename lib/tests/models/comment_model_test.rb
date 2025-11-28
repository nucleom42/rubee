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
    def include_and_validate(required: true)
      Comment.include(Rubee::Validatable)
      required_or_optional = required ? :required : :optional
      required_or_optional_args = required ? [:text, required: "text filed is required"] : [:text]
      Comment.validate do |comment|
        comment.send(
          required_or_optional, *required_or_optional_args
        )
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

    describe 'when first validation is optional' do
      it 'no text should be valid' do
        include_and_validate required: false

        comment = Comment.new(user_id: 1)

        _(comment.valid?).must_equal(true)
        _(comment.errors[:test]).must_equal(nil)
      end

      it 'text is a number should be invalid' do
        include_and_validate required: false
        comment = Comment.new(text: 1)

        _(comment.valid?).must_equal(false)
        _(comment.errors[:text]).must_equal({ type: "text field must be string" })
      end

      it 'text is short should be invalid' do
        include_and_validate required: false
        comment = Comment.new(text: 'test')

        _(comment.valid?).must_equal(false)
        _(comment.errors[:text]).must_equal({ length: "text length must be greater than 4" })
      end
    end

    describe 'before save must be valid' do
      it 'does not persit if record is invalid' do
        include_and_validate
        Comment.before(:save, ->(c) { binding.pry; raise StandardError }, if: ->(comment) { comment&.invalid? })

        comment = Comment.new(text: 'test')

        _(raise_error { comment.save }.is_a?(StandardError)).must_equal(true)
        _(comment.persisted?).must_equal(false)
      end

      describe 'when usig method' do
        it 'does not persit if record is invalid' do
          include_and_validate
          Comment.before(:save, -> { raise StandardError }, if: :invalid?)

          comment = Comment.new(text: 'test')

          _(raise_error { comment.save }.is_a?(StandardError)).must_equal(true)
          _(comment.persisted?).must_equal(false)
        end
      end
    end

    describe 'before create must be invalid' do
      it 'does not create if record is invalid' do
        include_and_validate
        Comment.before(:save, -> { raise StandardError }, if: :invalid?)

        initial_comments_count = Comment.count
        _(raise_error { Comment.create(text: 'te') }.is_a?(StandardError)).must_equal(true)
        assert_equal(initial_comments_count, Comment.count)
      end
    end

    describe 'before update must be invalid' do
      it 'does not update if record is invalid' do
        include_and_validate
        Comment.before(:save, -> { raise StandardError }, if: :invalid?)

        initial_comments_count = Comment.count
        _(raise_error { Comment.find(1).update(text: 'te') }.is_a?(StandardError)).must_equal(true)
        assert_equal(initial_comments_count, Comment.count)
      end
    end
  end
end
