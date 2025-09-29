class Address < Rubee::SequelObject
  attr_accessor :id, :street, :apt, :city, :state, :zip, :user_id, :created, :updated

  holds :user
end
