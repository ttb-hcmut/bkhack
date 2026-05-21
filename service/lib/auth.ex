defmodule AuthBE do
  import Ecto.Query
  def login(username,password) do
    from(u in User, where: u.name == ^username and u.password == ^password, select: %{user_id: u.user_id,name: u.name})
    |> Data0.one
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
  def register(username,password,email,role\\0) do
    changeset = User.changeset(%User{}, %{
      email:    email,
      name:     username,
      password: password,
      role:     role,
    })
    case Data0.insert(changeset) do
      {:ok, _user} -> ""
      {:error, changeset} -> errorMessage(changeset)
    end
  end

  def getAll do
    query = from u in User, select: u
    xs = Data0.all(query)
    IO.inspect xs
  end
end
