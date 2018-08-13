# Elixir RDAP Client

[![CircleCI](https://circleci.com/gh/mroach/elixir-rdap.svg?style=svg)](https://circleci.com/gh/mroach/elixir-rdap)

> This is my first Elixir package/library. It's not yet complete and isn't yet intended for use. API may/will change and there are probably all kinds of problems with it. You've been warned :)

Queries [RDAP] (Registration Data Access Protocol) servers for network information. RDAP is the planned successor to WHOIS. RDAP is a REST-based protocol where the servers return standardised JSON, making it easier to consume than classic WHOIS.

```shell
curl rdap.arin.net/registry/ip/8.8.8.8 | jq
```

This library uses the [IANA RDAP bootstrap data] to identify which RDAP server should have the information about an IPv4 address. This prevents unnecessary follow-up queries. For example if you query ARIN for an IP in Europe, you'll then have to connect to RIPE to get the information. Not ideal.

## Example usage

```elixir
RDAP.lookup_ip "8.8.8.8"

%{:ok,
  %{
    ...
    "name" => "LVLT-GOGL-8-8-8"
    ...
  }
}
```

## Installation

> Not yet available in Hex

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `rdap` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:rdap, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/exrdap](https://hexdocs.pm/exrdap).

## TODO

* Support IPv6 addresses
* Support custom RDAP servers
* Cache responses by network. For example if querying a specific IP and the reply indicates the owner is a /24 block, cache the whole block so future lookups hit the cache.
* Ignore non-routable IPs

[RDAP]: https://en.wikipedia.org/wiki/Registration_Data_Access_Protocol
[IANA RDAP bootstrap data]: http://data.iana.org/rdap/
