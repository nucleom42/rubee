STRUCTURE = {
  accounts: {
    columns: {
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
      addres: {
        generated: false,
        allow_null: true,
        default: nil,
        db_type: "varchar(255)",
        primary_key: false,
        type: "string",
        ruby_default: nil,
        max_length: 255
      },
      user_id: {
        generated: false,
        allow_null: true,
        default: nil,
        db_type: "INTEGER",
        primary_key: false,
        type: "integer",
        ruby_default: nil
      },
      created: {
        generated: false,
        allow_null: true,
        default: nil,
        db_type: "datetime",
        primary_key: false,
        type: "datetime",
        ruby_default: nil
      },
      updated: {
        generated: false,
        allow_null: true,
        default: nil,
        db_type: "datetime",
        primary_key: false,
        type: "datetime",
        ruby_default: nil
      }
    },
    foreign_keys: [
      {
        columns: [
          "user_id"
        ],
        references: {
          table: "users",
          columns: nil
        },
        on_delete: "no_action",
        on_update: "no_action"
      }
    ]
  },
  addresses: {
    columns: {
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
      city: {
        generated: false,
        allow_null: true,
        default: nil,
        db_type: "varchar(255)",
        primary_key: false,
        type: "string",
        ruby_default: nil,
        max_length: 255
      },
      state: {
        generated: false,
        allow_null: true,
        default: nil,
        db_type: "varchar(255)",
        primary_key: false,
        type: "string",
        ruby_default: nil,
        max_length: 255
      },
      zip: {
        generated: false,
        allow_null: true,
        default: nil,
        db_type: "varchar(255)",
        primary_key: false,
        type: "string",
        ruby_default: nil,
        max_length: 255
      },
      street: {
        generated: false,
        allow_null: true,
        default: nil,
        db_type: "varchar(255)",
        primary_key: false,
        type: "string",
        ruby_default: nil,
        max_length: 255
      },
      apt: {
        generated: false,
        allow_null: true,
        default: nil,
        db_type: "varchar(255)",
        primary_key: false,
        type: "string",
        ruby_default: nil,
        max_length: 255
      },
      user_id: {
        generated: false,
        allow_null: true,
        default: nil,
        db_type: "INTEGER",
        primary_key: false,
        type: "integer",
        ruby_default: nil
      },
      created: {
        generated: false,
        allow_null: true,
        default: nil,
        db_type: "datetime",
        primary_key: false,
        type: "datetime",
        ruby_default: nil
      },
      updated: {
        generated: false,
        allow_null: true,
        default: nil,
        db_type: "datetime",
        primary_key: false,
        type: "datetime",
        ruby_default: nil
      }
    },
    foreign_keys: [
      {
        columns: [
          "user_id"
        ],
        references: {
          table: "users",
          columns: nil
        },
        on_delete: "no_action",
        on_update: "no_action"
      }
    ]
  },
  carrots: {
    columns: {
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
      color: {
        generated: false,
        allow_null: false,
        default: nil,
        db_type: "varchar(255)",
        primary_key: false,
        type: "string",
        ruby_default: nil,
        max_length: 255
      },
      created: {
        generated: false,
        allow_null: true,
        default: nil,
        db_type: "datetime",
        primary_key: false,
        type: "datetime",
        ruby_default: nil
      },
      updated: {
        generated: false,
        allow_null: true,
        default: nil,
        db_type: "datetime",
        primary_key: false,
        type: "datetime",
        ruby_default: nil
      }
    },
    foreign_keys: []
  },
  clients: {
    columns: {
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
      name: {
        generated: false,
        allow_null: true,
        default: nil,
        db_type: "varchar(255)",
        primary_key: false,
        type: "string",
        ruby_default: nil,
        max_length: 255
      },
      digest_password: {
        generated: false,
        allow_null: true,
        default: nil,
        db_type: "varchar(255)",
        primary_key: false,
        type: "string",
        ruby_default: nil,
        max_length: 255
      },
      created: {
        generated: false,
        allow_null: true,
        default: nil,
        db_type: "datetime",
        primary_key: false,
        type: "datetime",
        ruby_default: nil
      },
      updated: {
        generated: false,
        allow_null: true,
        default: nil,
        db_type: "datetime",
        primary_key: false,
        type: "datetime",
        ruby_default: nil
      }
    },
    foreign_keys: []
  },
  comments: {
    columns: {
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
      text: {
        generated: false,
        allow_null: true,
        default: nil,
        db_type: "varchar(255)",
        primary_key: false,
        type: "string",
        ruby_default: nil,
        max_length: 255
      },
      user_id: {
        generated: false,
        allow_null: true,
        default: nil,
        db_type: "INTEGER",
        primary_key: false,
        type: "integer",
        ruby_default: nil
      },
      created: {
        generated: false,
        allow_null: true,
        default: nil,
        db_type: "datetime",
        primary_key: false,
        type: "datetime",
        ruby_default: nil
      },
      updated: {
        generated: false,
        allow_null: true,
        default: nil,
        db_type: "datetime",
        primary_key: false,
        type: "datetime",
        ruby_default: nil
      }
    },
    foreign_keys: []
  },
  users: {
    columns: {
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
      },
      created: {
        generated: false,
        allow_null: true,
        default: nil,
        db_type: "datetime",
        primary_key: false,
        type: "datetime",
        ruby_default: nil
      },
      updated: {
        generated: false,
        allow_null: true,
        default: nil,
        db_type: "datetime",
        primary_key: false,
        type: "datetime",
        ruby_default: nil
      }
    },
    foreign_keys: []
  },
  posts: {
    columns: {
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
      user_id: {
        generated: false,
        allow_null: true,
        default: nil,
        db_type: "INTEGER",
        primary_key: false,
        type: "integer",
        ruby_default: nil
      },
      comment_id: {
        generated: false,
        allow_null: true,
        default: nil,
        db_type: "INTEGER",
        primary_key: false,
        type: "integer",
        ruby_default: nil
      },
      created: {
        generated: false,
        allow_null: true,
        default: nil,
        db_type: "datetime",
        primary_key: false,
        type: "datetime",
        ruby_default: nil
      },
      updated: {
        generated: false,
        allow_null: true,
        default: nil,
        db_type: "datetime",
        primary_key: false,
        type: "datetime",
        ruby_default: nil
      }
    },
    foreign_keys: [
      {
        columns: [
          "comment_id"
        ],
        references: {
          table: "comments",
          columns: nil
        },
        on_delete: "no_action",
        on_update: "no_action"
      },
      {
        columns: [
          "user_id"
        ],
        references: {
          table: "users",
          columns: nil
        },
        on_delete: "no_action",
        on_update: "no_action"
      }
    ]
  }
}
