defmodule AuthBE do
  import Ecto.Query
  def makePackage(data,user_id)do
    with %User{} = user <- User |> select([u],u) |> where([u],u.user_id == ^user_id) |> data.one
    do
      %{
      user_id:   user.user_id                   ,
      user_name: user.name                      ,
      sign_at:   System.os_time(:second)        ,
      timeout:   System.os_time(:second) + 3600 ,
      }
    else
      _ -> {:error,"not a user"}
    end
  end
  def makeJWT(data,user_id) do
    with {:ok, secret} <- System.fetch_env("JWT_SECRET"),
         %{user_id: _,user_name: _,sign_at: _,timeout: _,} = package <- makePackage(data,user_id)
    do
      {:ok, jsonPackage} = package |> JSON.encode
      hashToken = :crypto.hash(:sha256, jsonPackage <> secret) |> Base.encode16
      Map.put(package,:hash, hashToken)
    else
      {:error, msg} -> IO.puts(msg); {:error, "balls"}
    end
  end

  def testJWT(token)do
    {:ok, secret} = System.fetch_env("JWT_SECRET")
    package = %{
      user_id:   Map.get(token, :user_id)  ,
      user_name: Map.get(token, :user_name),
      sign_at:   Map.get(token, :sign_at)  ,
      timeout:   Map.get(token, :timeout)  ,
    }
    {:ok, jsonPackage} = package |> JSON.encode
    hashToken = :crypto.hash(:sha256, jsonPackage <> secret) |> Base.encode16
    Map.get(token, :hash) == hashToken and Map.get(token, :timeout) > System.os_time(:second)
  end

  # def refreshJWT(data, user_id, user_name, timeout, sign_at, hash) do
  #   with true <- testJWT(user_id, user_name, timeout, sign_at, hash)
  #   do
  #     makeJWT(data,user_id)
  #   else
  #     _ -> nil
  #   end
  # end

  def login(data, username,password) do
    with %User{}= u <- User |> select([u],u) |> where([u], u.name == ^username and u.password == ^:crypto.hash(:sha256,password)) |> data.one
    do makeJWT(data,u.user_id) else _ -> nil end
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
      password: :crypto.hash(:sha256, password),
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
