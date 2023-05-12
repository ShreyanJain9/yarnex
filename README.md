# Yarnex

**TODO: Add description**

## Installation

<!-- If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `yarnex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:yarnex, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/yarnex>. -->


## Yarn-related stuff

The entirety of yarn.social-related logic in Elixir lives below:

```elixir 
defmodule Yarn do
  require HTTPoison
  require Poison
  @spec api_endpoint(any) :: <<_::64, _::_*8>>
  def api_endpoint(yarnpod) do
    "https://#{yarnpod}/api/v1"
  end

  @spec get_jwt_token(any, any, any) :: any
  def get_jwt_token(username, password, endpoint) do
    body = %{username: username, password: password}
    headers = %{"Content-Type" => "application/json"}

    {:ok, response} = HTTPoison.post("#{endpoint}/auth", Poison.encode!(body), headers)
    response_body = Poison.decode!(response.body)

    response_body["token"]
  end

  @spec authenticated_headers(any) :: %{optional(<<_::40, _::_*56>>) => binary}
  def authenticated_headers(token) do
    %{"Token" => "#{token}", "Content-Type" => "application/json"}
  end

  def post_twt(token, yarnpod, twt) do
    headers = authenticated_headers(token)
    endpoint = api_endpoint(yarnpod)
    body = %{text: twt, post_as: ""}
    {:ok, response} = HTTPoison.post("#{endpoint}/post", Poison.encode!(body), headers)
    Poison.decode!(response.body)

  end

end
```
That's everything it takes to implement a simple yarn.social client in Elixir! 

