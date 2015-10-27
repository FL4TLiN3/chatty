defmodule Chatty.Router do
  use Chatty.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_layout, { Chatty.LayoutView, :app }
  end

  pipeline :admin do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_layout, { Chatty.LayoutView, :admin }
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Chatty do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :spa
    get  "/login", AuthController, :show_login
    post "/login", AuthController, :login
    get  "/logout", AuthController, :logout
    get  "/auth/github", AuthGithubController, :auth
    get  "/auth/callback/github", AuthGithubController, :auth_callback
    get  "/signup", AuthController, :new
    post "/signup", AuthController, :create
    get  "/signup/profile", AuthController, :profile
    post "/signup/profile", AuthController, :update_profile
    put  "/signup/profile", AuthController, :update_profile
  end

  scope "/admin", Chatty do
    pipe_through :admin

    get "/", PageController, :spa
    resources "/stories", StoryController
    resources "/categories", CategoryController
    resources "/users", UserController
    resources "/feeds", FeedController
  end

  scope "/api", Chatty do
    pipe_through :api

    get  "/job/stats", JobController, :stats
    post "/job", JobController, :create
  end
end
