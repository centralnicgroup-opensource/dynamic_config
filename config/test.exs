use Mix.Config

config :dynamic_config,
  config_db: "config",
  interval: 10_000,
  targets: [
    {target: :nsearch3, source: "nsearch", backend: DynamicConfig.CouchDB}
    {target: :nsearch3.Hexonet, source: "hexonet/search", backend: DynamicConfig.Vault}
  ]
