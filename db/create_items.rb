require 'sequel'

class CreateItems
  DB = Sequel.sqlite('db/development.sqlite3')
  def call
    # return puts DB[:items] if DB[:items]

    unless DB.tables.include?(:items)
      DB.create_table :items do
        primary_key :id
        String :name
        Float :price
      end
    end

    items = DB[:items] # Create a dataset

    # Populate the table
    items.insert(name: 'abc', price: rand * 100)
    items.insert(name: 'def', price: rand * 100)
    items.insert(name: 'ghi', price: rand * 100)

    puts "Items count is #{items.count}"
  end
end

