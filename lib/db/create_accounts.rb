class CreateAccounts
  def call
    unless Rubee::SequelObject::DB.tables.include?(:accounts)
      Rubee::SequelObject::DB.create_table :accounts do
        primary_key :id
        String :addres
        foreign_key :user_id, :users
      end

      Account.create(addres: "13th Ave, NY", user_id: User.all.first.id)
      Account.create(addres: "14th Ave, NY", user_id: User.all.last.id)
    end
  end
end
