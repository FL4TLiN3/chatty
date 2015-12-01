defmodule Chatty.State do

  alias Phoenix.Socket

  def get(state, key) do
    Dict.get state, key
  end

  def set(state, :cid, _), do: state
  def set(state, :cname, _), do: state
  def set(state, key, value) do
    Dict.put state, key, value
  end
end
