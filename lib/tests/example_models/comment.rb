class Comment < Rubee::SequelObject
  attr_accessor :id, :content
  owns_many :users, over: :posts
end
