import Config

config :bkhack, Data0, database: "db"

config :bkhack, Data1, adapter:  Mongo.Ecto, database: "main",
  username: "kinten", password: "kinten", hostname: "localhost"
