defmodule AuthBE do
  import Ecto.Query
  def login(data, username,password) do
    from(u in User, where: u.name == ^username and u.password == ^password, select: %{user_id: u.user_id,name: u.name})
    |> data.one
  end
  def getErrors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
  def errorMessage(changeset) do
  changeset
  |> getErrors()
  |> Enum.map(fn {field, errors} ->
      "#{field}: #{Enum.join(errors, ", ")}"
    end)
  |> Enum.join("\n")
end
  def register(data, username,password,email,role\\0) do
    changeset = User.changeset(%User{}, %{
      email:    email,
      name:     username,
      password: password,
      role:     role,
    })
    case data.insert(changeset) do
      {:ok, _user} -> ""
      {:error, changeset} -> errorMessage(changeset)
    end
  end

  def getAll(data) do
    query = from u in User, select: u
    xs = data.all(query)
    IO.inspect xs
  end
end
