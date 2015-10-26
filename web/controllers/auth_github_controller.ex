defmodule Chatty.AuthGithubController do
  use Chatty.Web, :controller

  alias Chatty.Auth.Credential
  alias Chatty.Auth.GitHub
  alias Chatty.User
  alias Chatty.UserProfile

  plug :put_layout, { Chatty.LayoutView, :nosidebar }

  def auth(conn, _params) do
    conn
    |> redirect external: GitHub.authorize_url!
  end

  def auth_callback(conn, %{"code" => code}) do
    token = GitHub.get_token!(code: code)
    github_user = OAuth2.AccessToken.get!(token, "/user")
    user = Repo.one(from u in User, where: u.email == ^github_user["email"])

    if user do
      conn
      |> login(user, token, github_user)
    else
      conn
      |> signup(token, github_user)
    end
  end

  defp login(conn, user, token, github_user) do
    conn
    |> put_session(:user, user)
    |> redirect(to: page_path(conn, :spa))
  end

  defp signup(conn, token, github_user) do
    user = Repo.insert! %User{
      email: github_user["email"],
      github_access_token: token.access_token}

    credentials = Credential.get_credentials user
    user = Repo.update! %{user |
      access_secret: credentials.access_secret,
      access_secret_generated_at: credentials.access_secret_generated_at |> Ecto.DateTime.from_erl,
      access_token: credentials.access_token,
      access_token_expires_at: credentials.access_token_expires_at |> Ecto.DateTime.from_erl}

    Repo.insert! %UserProfile{
      user_id: user.id,
      name: github_user["name"],
      location: github_user["location"],
      bio: github_user["bio"]}

    conn
    |> put_flash(:info, "User created successfully.")
    |> put_session(:user, user)
    |> redirect(to: auth_path(conn, :profile))
  end
end
