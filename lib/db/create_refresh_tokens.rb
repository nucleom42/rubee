class CreateRefreshTokens
  def call
    return if Rubee::SequelObject::DB.tables.include?(:refresh_tokens)

    Rubee::SequelObject::DB.create_table(:refresh_tokens) do
      primary_key(:id)
      String(:token_hash, null: false, unique: true)
      String(:user_class, null: false)
      String(:login_field, null: false)
      String(:login_value, null: false)
      DateTime(:expires_at, null: false)
      DateTime(:revoked_at)
      DateTime(:created)
      DateTime(:updated)
      index(:token_hash)
      index(:user_class)
    end
  end
end
