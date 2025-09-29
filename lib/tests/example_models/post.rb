class Post < Rubee::SequelObject
  attr_accessor :id, :user_id, :comment_id, :created, :updated

  holds :comment
  holds :user
end
