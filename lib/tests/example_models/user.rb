class User < Rubee::SequelObject
  attr_accessor :id, :email, :password, :role, :created, :updated

  owns_many :accounts, cascade: true
  owns_one :address, cascade: true

  # Mandatory hash const required for authorizable
  ROLES = { admin: 1, user: 0 }.freeze
end
