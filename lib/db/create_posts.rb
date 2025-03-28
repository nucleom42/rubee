class CreateUsers
  def call
    unless Rubee::SequelObject::DB.tables.include?(:users)
      Rubee::SequelObject::DB.create_table :users do
        primary_key :id
        String :email
        String :password
        index :email
      end

      User.create(email: "ok@ok.com", password: "password")
    end
  end
end
