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

    get "/", PageController, :index
  end

  scope "/admin", Chatty do
    pipe_through :admin

    get "/", PageController, :spa
    resources "/users", UserController
  end

  # Other scopes may use custom stacks.
  # scope "/api", Chatty do
  #   pipe_through :api
  # end
end
