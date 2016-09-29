defmodule Rumbl.Permalink do
  # Permalink is a custom type defined according to the Ecto.Type behavior
  # this is to associate some behavior to the `id` field
  @behavior Ecto.Type

  # underlying Ecto type
  def type, do: :id

  # Called when external data is passed into Ecto
  def cast(binary) when is_binary(binary) do
    # extract only the leading integer
    case Integer.parse(binary) do
      {int, _} when int > 0 -> {:ok, int}
      _ -> :error
    end
  end

  def cast(integer) when is_integer(integer) do
    {:ok, integer}
  end

  def cast(_) do
    :error
  end

  # dump and load handle the struct-to-database conversion

  # Invoked when data is sent to the database
  def dump(integer) when is_integer(integer) do
    {:ok, integer}
  end

  # Invoked when data is loaded from the database
  def load(integer) when is_integer(integer) do
    {:ok, integer}
  end
end
