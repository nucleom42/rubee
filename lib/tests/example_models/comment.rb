class Comment < Rubee::SequelObject
  attr_accessor :id, :text, :user_id, :created, :updated

  owns_many :users, over: :posts
end
