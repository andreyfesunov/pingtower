import Config

config :ping_workers, :mongodb, %{
  host: "localhost",
  port: 27017,
  username: "admin",
  password: "admin",
  database: "ping_workers",
  auth_database: "admin",
  ssl: false,
  timeout: 5000
}
