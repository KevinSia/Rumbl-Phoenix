defmodule Rumbl.User do
  # struct is Elixir’s main abstraction for working with structured data.
  # used for stubbing an Ecto repo for chapter 2
  # defstruct [:id, :name, :username, :password]

  use Rumbl.Web, :model

  # Ecto has a DSL that *specifies the fields in a struct* and the *mapping between those fields and the database tables*.
  # This DSL is built with Elixir macros.
  # The schema and field macros let us specify both the underlying database table and the Elixir struct
  # Each field corresponds to both a field in the database and a field in our local User struct
  schema "users" do
    field :name, :string
    field :username, :string
    field :password, :string, virtual: true # virtual field are not persisted to the database
    field :description, :string, virtual: true
    field :password_hash, :string
    has_many :videos, Rumbl.Video
    has_many :annotations, Rumbl.Annotation
    timestamps
  end
  # the above schema is created automatically in Rails.
  # it is created in such a manual way in Phoenix for the speed improved for not letting the computer to figure out
  # the schema

  # If no parameters are specified, we can’t just default to an empty map,
  # because that would be indistinguishable from a blank form submission
  # Ecto is using changesets as a bucket to hold everything related to a database change, before and after persistence
  def changeset(model, params \\ :invalid) do
    model
    # cast makes sure we provide all necessary required fields
    # name and username are required, no optional fields
    # changeset ignores password for now
    |> cast(params, ~w(name username), [:description])
    # validation
    |> validate_length(:username, min: 1, max: 20)
    |> unique_constraint(:username)
  end

  # Each changeset encapsulates the whole change policy!
  # allowed fields, detecting change, validations, and messaging the user

  # Using changeset constraints only makes sense if the error message can be something the user can take action on.

  def registration_changeset(model, params \\ :invalid) do
    model
    |> changeset(params)
    |> cast(params, ~w(password), []) # Q: cast function takes in a changeset or model as first argument?
    |> validate_length(:password, min: 6, max: 100)
    |> put_pass_hash()
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end
end
