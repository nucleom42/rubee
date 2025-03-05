class CreateApples
  def call
    unless SequelObject::DB.tables.include?(:apples)
      SequelObject::DB.create_table :apples do
        primary_key :id
        String :color
        Integer :weight
      end

      Apple.create(color: "red", weight: 100)
      Apple.create(color: "green", weight: 150)
      Apple.create(color: "orange", weight: 110)
      Apple.create(color: "white", weight: 200)
    end
  end
end
