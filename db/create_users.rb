# This migration is a prerequisite for the inbuild JWT authentification logic
# Please make sure you executed it before using AuthTokenable module
class CreateUsers
  def call
    unless DB.tables.include?(:users)
      DB.create_table :users do
        primary_key :id
        String :email
        String :password
        index :email
      end

      User.create(email: "ok@ok.com", password: "password")
    end
  end
end
