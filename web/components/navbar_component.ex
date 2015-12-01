defmodule Chatty.NavbarComponent do
  use Phoenix.Channel
  import Chatty.Component

  def init(context, payload) do
    context
    |> patch "unauthorized.html", payload
  end
end
