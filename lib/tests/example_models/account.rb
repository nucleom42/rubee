class Account < Rubee::SequelObject
  attr_accessor :id, :addres, :user_id, :created, :updated

  holds :user
end
