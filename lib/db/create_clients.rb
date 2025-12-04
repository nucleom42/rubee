class CreateClients
  def call
    return if Rubee::SequelObject::DB.tables.include?(:clients)

    Rubee::SequelObject::DB.create_table(:clients) do
      primary_key(:id)
      String(:name)
      String(:digest_password)
      index(:name)
      # timestamps
      datetime(:created)
      datetime(:updated)
    end
  end
end
