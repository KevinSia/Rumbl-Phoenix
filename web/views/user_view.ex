defmodule Rumbl.UserView do
  use Rumbl.Web, :view
  alias Rumbl.User

  def first_name(%User{name: name}) do
    name
      |> String.split(" ")
      |> Enum.at(0)
  end

  # view is the presentation layer of the templates,
  # which will be compiled into functions before runtime!
  # also, templates are built using linked lists, instead of string concatenation (used by most of the websites)
end
