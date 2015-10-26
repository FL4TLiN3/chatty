defmodule Chatty.Auth.Credential do

  use Timex
  alias Chatty.User

  def get_credentials(user) do
    secret = get_access_secret user
    token  = get_access_token secret
    Dict.merge(secret, token)
  end

  def get_access_secret(%User{id: id}) do
    conf = Mix.Config.read!("config/config.exs")
    access_secret_generated_at = :calendar.universal_time
    format = access_secret_generated_at |> Date.from |> DateFormat.format!("{ISO}")
    raw_access_secret = [id, format, conf[:chatty][:hash_salt]]
    access_secret = :crypto.hash(:sha256, raw_access_secret) |> Base.encode16
    %{access_secret: access_secret, access_secret_generated_at: access_secret_generated_at}
  end

  def get_access_token(%{access_secret: access_secret, access_secret_generated_at: access_secret_generated_at}) do
    conf = Mix.Config.read!("config/config.exs")
    access_token_expires_at= access_secret_generated_at
                             |> Date.from
                             |> Date.shift(days: 30)
                             |> DateConvert.to_erlang_datetime
    format = access_token_expires_at |> Date.from |> DateFormat.format!("{ISO}")
    raw_access_token = [access_secret, format, conf[:chatty][:hash_salt]]
    access_token = :crypto.hash(:sha256, raw_access_token) |> Base.encode16
    %{access_token: access_token, access_token_expires_at: access_token_expires_at}
  end
end
