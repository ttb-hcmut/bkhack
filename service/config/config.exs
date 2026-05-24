import Config

# config :bkhack, Data0, database: "db"

# config :bkhack, Data1, adapter:  Mongo.Ecto, database: "main",
#   username: "kinten", password: "kinten", hostname: "localhost"

config :bkhack, Data0,
  hostname: "db.dojhbipasrejjurzremz.supabase.com",
  port: 5432,
  username: "postgres",
  password: System.fetch_env!("BKHACK_SUPABASE_PASSWORD"),
  database: "postgres",
  socket_options: [:inet6]
