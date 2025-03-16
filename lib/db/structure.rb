STRUCTURE = {
  users: {
    id: {
      generated: false,
      allow_null: false,
      default: nil,
      db_type: "INTEGER",
      primary_key: true,
      auto_increment: true,
      type: "integer",
      ruby_default: nil
    },
    email: {
      generated: false,
      allow_null: true,
      default: nil,
      db_type: "varchar(255)",
      primary_key: false,
      type: "string",
      ruby_default: nil,
      max_length: 255
    },
    password: {
      generated: false,
      allow_null: true,
      default: nil,
      db_type: "varchar(255)",
      primary_key: false,
      type: "string",
      ruby_default: nil,
      max_length: 255
    }
  }
}
