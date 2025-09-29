class CreateAddresses
  def call
    return if Rubee::SequelObject::DB.tables.include?(:addresses)

    Rubee::SequelObject::DB.create_table(:addresses) do
      primary_key(:id)
      String(:city)
      String(:state)
      String(:zip)
      String(:street)
      String(:apt)
      foreign_key(:user_id, :users)
      # timestamps
      datetime(:created)
      datetime(:updated)
    end

    # Address.create(street: '13th Ave', city: 'NY', state: 'NY', zip: '55555', user_id: User.all.first.id)
  end
end
