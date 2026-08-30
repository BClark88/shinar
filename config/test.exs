import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :shinar, Shinar.Repo,
  database: Path.expand("../shinar_test.db", __DIR__),
  pool_size: 5,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :shinar, ShinarWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "8a0538cFvAjq4NslAQRbmQ5cBHbR66otWvslx+RyzRqVH/2z7F6l3hNPsZ3uEIWg",
  server: false

# In test we don't send emails
config :shinar, Shinar.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Route LLM HTTP calls through Req.Test stubs in tests instead of the local Ollama server.
config :shinar, :llm, req_options: [plug: {Req.Test, Shinar.LLM.Client}]

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Sort query params output of verified routes for robust url comparisons
config :phoenix,
  sort_verified_routes_query_params: true
