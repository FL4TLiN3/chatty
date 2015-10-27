defmodule Chatty.SidebarComponent do
  use Phoenix.Channel

  def join("sidebar:unauthorized", _message, socket) do
    html = Phoenix.View.render_to_string(Chatty.SidebarComponentView, "unauthorized.html", %{})
    {:ok, %{html: html}, socket}
  end

end
