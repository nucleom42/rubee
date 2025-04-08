# frozen_string_literal: true

class Post < Rubee::SequelObject
  attr_accessor :id, :user_id, :comment_id

  holds :comment
  holds :user
end
