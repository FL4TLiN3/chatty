defmodule Chatty.NavbarComponent do
  use Phoenix.Channel

  def join("navbar:unauthorized", _message, socket) do
    html = Phoenix.View.render_to_string(Chatty.NavbarComponentView, "unauthorized.html", %{})
    {:ok, %{html: html}, socket}
  end

  def join("rooms:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast! socket, "new_msg", %{body: body}
    {:noreply, socket}
  end

  def handle_out("new_msg", payload, socket) do
    push socket, "new_msg", payload
    {:noreply, socket}
  end
end
