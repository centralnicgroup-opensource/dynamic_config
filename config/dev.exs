use Mix.Config

config :dynamic_config,
  config_db: "config",
  interval: 10_000,
  targets: [
    %{target: :couchex, source: "secret/couchdb", backend: DynamicConfig.Vault},
    %{target: :nsearch3, source: "nsearch3", backend: DynamicConfig.CouchDB}
  ]

config :vaultex,
  app_id:    "foo",
  role_id:   File.read!("../vaultex/.role_id") |> String.trim,
  secret_id: File.read!("../vaultex/.secret_id") |> String.trim

