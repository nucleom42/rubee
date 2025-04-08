# frozen_string_literal: true

class User < Rubee::SequelObject
  attr_accessor :id, :email, :password

  owns_many :accounts, cascade: true
end
