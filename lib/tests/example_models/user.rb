class User < Rubee::SequelObject
  attr_accessor :id, :email, :password, :created, :updated

  owns_many :accounts, cascade: true
  owns_one :address, cascade: true
end
