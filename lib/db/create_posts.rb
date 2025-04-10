class CreatePosts
  def call
    return if Rubee::SequelObject::DB.tables.include?(:posts)

    Rubee::SequelObject::DB.create_table(:posts) do
      primary_key(:id)
      foreign_key(:user_id, :users)
      foreign_key(:comment_id, :comments)
    end

    Post.create(user_id: User.all.first.id, comment_id: Comment.all.first.id)
    Post.create(user_id: User.all.last.id, comment_id: Comment.all.last.id)
  end
end
