# DynamicConfig

Having the option to manage config in a database and update application
behaviour by changing DB documents is handy especially if things break
and running commands on all affected machines is slow.

This app handles application configuration and updates it every n
seconds to make sure that we can tweak application behaviour on the fly.
It currently only supports CouchDB but could easily be extended to
support other backends by implementing a new `DynamicConfig.BACKEND`
module.

## Installation

This is currently not published to Hex so pull it from git by adding
this to your dependencies:

```elixir
def deps do
  [{:dynamic_config, github: "norbu09/dynamic_config"}]
end
```

## Usage

By adding the dependency and adding `:dynamic_config` to your
applications the app will start a GenServer at application startup. This
GenServer will trigger a read to the backend for updated config settings
and update the application config if something changed. It currently
determines changes by looking at the document revision of the config
document. To configure behaviour of the application please add the
following configuration parameter to your application:

```elixir
:dynamic_config,
  update: APPLICATION_NAME, # defaults to :dynamic_config
  interval: 10_000,         # update interval, defaults to 50_000 (5min)
  config_db: "conf"         # defaults to "config"
```

The `update` part is the most important one as it defines the
application environment we want to modify, this would normally be your
main application. Say your main app is `:my_app` then the dynamic
updater would add every key in the document with the `_id: "my_app"` to
your `:my_app` application environment.

