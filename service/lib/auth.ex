defmodule AuthBE do
  def login(username,password) do
    import Ecto.Query
    from(u in User, where: u.name == ^username and u.password == ^password, select: %{user_id: u.user_id,name: u.name})
    |> Data0.one
  end
end
