class CreateComments
  def call
    return if Rubee::SequelObject::DB.tables.include?(:comments)

    Rubee::SequelObject::DB.create_table(:comments) do
      primary_key(:id)
      String(:text)
      Integer(:user_id)
      # timestamps
      datetime(:created)
      datetime(:updated)

    end

    User.create(email: 'ok@ok.com', password: 'password')
  end
end
