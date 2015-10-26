defmodule Chatty.Auth.GitHub do
  use OAuth2.Strategy

  def new do
    OAuth2.new([
      strategy: __MODULE__,
      client_id: "911db6ec05b48258b89f",
      client_secret: "0f2db89e540c9e6aac07cf221a539a268e457409",
      redirect_uri: "http://localhost:4000/auth/callback/github",
      site: "https://api.github.com",
      authorize_url: "https://github.com/login/oauth/authorize",
      token_url: "https://github.com/login/oauth/access_token"
    ])
  end

  def authorize_url!(params \\ []) do
    new()
    |> put_param(:scope, "user")
    |> OAuth2.Client.authorize_url!(params)
  end

  def get_token!(params \\ [], headers \\ [], options \\ []) do
    OAuth2.Client.get_token!(new(), params, headers, options)
  end

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end
