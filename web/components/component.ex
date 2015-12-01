
defmodule Chatty.Component do

  use Chatty.Web, :channel
  alias Phoenix.View
  alias Chatty.State

  def patch(context, template, payload) do
    context
    |> get_view
    |> render_html(template, payload)
    |> parse
    |> get_changelist
    |> convert_to_ops
    |> push_to_client(payload)
  end

  def noop(context, payload) do
    context
    |> push_noop_to_client(payload)
  end

  def get_view(context = {_, %{cname: cname}}) do
    {context, String.to_atom("Elixir.Chatty.#{cname}ComponentView")}
  end

  def render_html({context, view}, template, assigns) do
    {context, View.render_to_string(view, template, assigns)}
  end

  def parse({context, html}) do
    {context, html |> Floki.parse |> put_vdomid |> cleanup}
  end

  def get_changelist({{socket, state = %{vdom: current_vdom}}, new_vdom}) do
    changelist = diff(new_vdom, current_vdom)
    state = State.set state, :vdom, new_vdom
    {{socket, state}, changelist}
  end

  def get_changelist({{socket, state}, new_vdom}) do
    changelist = [{:insert_node, nil, new_vdom}]
    state = State.set state, :vdom, new_vdom
    {{socket, state}, changelist}
  end

  def convert_to_ops({context, changelist}) do
    ops = Enum.map(changelist, fn(change) ->
      case change do
        {:insert_node, target, vdom} ->
          %{type: "insert_node", target: target, value: vdom |> Floki.raw_html}
        {:replace_text, target, text} ->
          %{type: "replace_text", target: target, value: text}
      end
    end)
    {context, ops}
  end

  def push_to_client({{socket, state}, ops}, payload) do
    push socket, "patch", %{cid: State.get(state, :cid), ops: ops, ts: payload["ts"]}
    {socket, state}
  end

  def push_noop_to_client({socket, state}, payload) do
    push socket, "noop", %{cid: State.get(state, :cid), ts: payload["ts"]}
  end

  defp to_html(dom) do
    dom |> Floki.raw_html
  end

  defp cleanup(vdom) do
    if is_list vdom do
      vdom
    else
      [vdom]
    end
  end

  defp put_vdomid({tag_name, attr, children}) do
    attr = attr ++ [{"data-vdomid", "0"}]
    children = traversal children, [0], 0
    {tag_name, attr, children}
  end

  defp put_vdomid(node_list) when is_list(node_list) do
    traversal(node_list, [], 0)
  end

  defp put_vdomid(s) when is_binary(s), do: s

  defp put_vdomid({tag_name, attr, children}, parent_ids, nth_child) do
    attr = attr ++ [{"data-vdomid", gen_vdomid(parent_ids, nth_child)}]
    children = traversal children, parent_ids ++ [nth_child], 0
    {tag_name, attr, children}
  end

  defp put_vdomid(s, _, _) when is_binary(s), do: s

  defp put_vdomid(node_list) when is_list(node_list) do
    traversal(node_list, [], 0)
  end

  defp gen_vdomid(parent_ids, nth_child) do
    lsid = parent_ids ++ [nth_child]
    Enum.map_join lsid, ".", &(&1)
  end

  defp traversal([hd|tl], parent_ids, nth_child) do
    hd = put_vdomid hd, parent_ids, nth_child
    tl = traversal tl, parent_ids, nth_child + 1

    if is_nil(tl) do
      [hd]
    else
      [hd] ++ tl
    end
  end

  defp traversal([], parent_ids, nth_child), do: nil

  # defp diff(newer_node, older) when is_tuple newer_node do
    # case find_node newer_node, older do
      # nil ->
        # {:new, newer_node}
      # found when is_tuple found ->
        # {:unchanged, newer_node}
    # end
  # end

  def diff([n_hd|n_tl], [o_hd|o_tl]) do
    {n_tag_name, n_attrs, n_children} = n_hd
    {o_tag_name, o_attrs, o_children} = o_hd

    changes = [] ++ diff n_tl, o_tl

    # if n_tag_name != o_tag_name do
      # changes = changes ++ [{:remove_node, o_hd}]
      # changes = changes ++ [{:insert_node, n_hd}]
    # end


    changes = changes ++ diff_children(n_children, o_children, o_hd)
  end

  def diff([n_hd|n_tl], []) do
    changes = diff n_tl, []
  end

  def diff([], []), do: []

  defp diff_children([n_child_hd|n_child_tl], [o_child_hd|o_child_tl], target) when is_binary n_child_hd and is_binary o_child_hd do
    changes = [] ++ diff_children n_child_tl, o_child_tl, target

    if n_child_hd != o_child_hd do
      {_, t_attrs, _} = target
      {_, vdomid} = Enum.find(t_attrs, fn({key, value}) -> key == "data-vdomid" end)
      changes ++ [{:replace_text, vdomid, n_child_hd}]
    else
      changes
    end
  end

  defp diff_children([n_child_hd|n_child_tl], [o_child_hd|o_child_tl], target) do
    {n_tag_name, n_attrs, _} = n_child_hd
    {o_tag_name, o_attrs, _} = o_child_hd

    changes = [] ++ diff_children n_child_tl, o_child_tl, target
    changes ++ diff [n_child_hd], [o_child_hd]
  end

  defp diff_children([n_child_hd|n_child_tl], [], target) do
    changes = diff_children n_child_tl, [], target

    {_, t_attrs, _} = target
    {_, vdomid} = Enum.find(t_attrs, fn({key, value}) -> key == "data-vdomid" end)
    changes ++ [{:insert_node, vdomid, n_child_hd}]
  end

  defp diff_children([], [], _), do: []

  defp find_node(newer_node, [hd|tl]) do
    find_node newer_node, tl
    find_node newer_node, hd
  end

  defp find_node(newer_node, []), do: nil

  defp find_node({n_tag_name, n_attr, _}, older = {o_tag_name, o_attr, _}) do
    if n_tag_name == o_tag_name do
      case same_attr? n_attr, o_attr do
        {:ok} ->
          nil
        {:changed, change_list} ->
          change_list
      end
    else
      nil
    end
  end

  defp same_attr?(n_attrs, o_attrs) do
    changes = []

    Enum.map(n_attrs, fn ({n_key, n_value}) ->
      added_key = true

      Enum.map(o_attrs, fn ({o_key, o_value}) ->
        if n_key == o_key do
          added_key = false
          if n_value != o_value do
            changes = changes ++ [{:value_changed, n_key, n_value, o_value}]
          end
        end
      end)

      if added_key do
        changes = changes ++ [{:key_added, n_key, n_value}]
      end
    end)

    Enum.map(o_attrs, fn ({o_key, o_value}) ->
      removed_key = true

      Enum.map(n_attrs, fn ({n_key, n_value}) ->
        if n_key == o_key, do: removed_key = false
      end)

      if removed_key do
        changes = changes ++ [{:key_removed, o_key}]
      end
    end)

    if length(changes) > 0 do
      {:changed, changes}
    else
      {:ok}
    end
  end
end
