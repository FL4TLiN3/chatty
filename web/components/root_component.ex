
defmodule Chatty.RootComponent do
  use Chatty.Web, :channel
  use Timex

  alias Phoenix.Socket
  alias Chatty.State
  alias Chatty.Component

  def join("ashes", _message, socket) do
    {:ok, nil, socket}
  end

  def handle_in("initialize", payload = %{"cid" => cid, "cname" => cname}, socket) do
    socket
    |> get_context(cid, cname)
    |> get_component
    |> apply_to_component("init", payload)
    |> save_state
    |> noreply
  end

  def handle_in(message, payload = %{"cid" => cid}, socket) do
    {socket, state} = socket
    |> get_context(cid)
    |> get_component
    |> apply_to_component(message, payload)
    |> save_state
    |> noreply
  end

  defp get_context(socket, cid) do
    states = socket.assigns[:states]
    {socket, Dict.pop(states, cid)}
  end

  defp get_context(socket, cid, cname) do
    {socket, %{cid: cid, cname: cname}}
  end

  defp get_component({socket, state = %{cname: cname}}) do
    {{socket, state}, String.to_atom("Elixir.Chatty.#{cname}Component")}
  end

  defp apply_to_component({context, component}, message, payload) do
    apply(component, String.to_atom(message), [context, payload])
  end

  defp save_state({socket, state}) do
    cid = State.get(state, :cid)

    if is_nil socket.assigns[:states] do
      socket = Socket.assign(socket, :states, Dict.put(%{}, cid, state))
    else
      socket = Socket.assign(socket, :states, Dict.put(socket.assigns[:states], cid, state))
    end

    {socket, state}
  end

  defp noreply({socket, state}) do
    {:noreply, socket}
  end
end
