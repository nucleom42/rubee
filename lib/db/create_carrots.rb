class CreateCarrots
  def call
    return if Rubee::SequelObject::DB.tables.include?(:carrots)

    Rubee::SequelObject::DB.create_table(:carrots) do
      primary_key(:id)
      String(:color, null: false)
      # timestamps
      datetime(:created)
      datetime(:updated)
    end
  end
end
