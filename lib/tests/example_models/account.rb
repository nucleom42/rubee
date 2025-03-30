class Account < Rubee::SequelObject
  attr_accessor :id, :addres, :user_id
  holds :user
end
