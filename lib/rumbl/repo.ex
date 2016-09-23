  defmodule Rumbl.Repo do
  # connects to the database
  use Ecto.Repo, otp_app: :rumbl

  @moduledoc """
    In memory repository.
  """

  # quick stub for Ecto repository for Chapter 2
  # def all(Rumbl.User) do
  #   [
  #     %Rumbl.User{id: "1", name: "Kevin", username: "kskm", password: "123456"},
  #     %Rumbl.User{id: "2", name: "Ming Xiang", username: "cmx", password: "123456"},
  #     %Rumbl.User{id: "3", name: "Ping", username: "cyp", password: "123456"}
  #   ]
  # end
  #
  # def all(_module), do: []
  #
  # def get(module, id) do
  #   Enum.find all(module), fn map -> map.id == id end
  # end
  #
  # def get_by(module, params) do
  #   Enum.find all(module), fn map ->
  #     Enum.all? params, fn {key, value} ->
  #       Map.get(map, key) == value
  #     end
  #   end
  # end
end
