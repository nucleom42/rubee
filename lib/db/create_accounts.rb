class CreateAccounts
  def call
    return if Rubee::SequelObject::DB.tables.include?(:accounts)

    Rubee::SequelObject::DB.create_table(:accounts) do
      primary_key(:id)
      String(:addres)
      foreign_key(:user_id, :users)
      # timestamps
      datetime(:created)
      datetime(:updated)
    end
  end
end
