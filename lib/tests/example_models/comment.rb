class Comment < Rubee::SequelObject
  attr_accessor :id, :text, :user_id

  owns_many :users, over: :posts
end
