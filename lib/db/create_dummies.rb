class CreateDummies
  def call
    return if Rubee::SequelObject::DB.tables.include?(:dummies)

    Rubee::SequelObject::DB.create_table(:dummies) do
      primary_key(:id)
      String(:color, null: false)
      # timestamps
      datetime(:created)
      datetime(:updated)
    end
  end
end
