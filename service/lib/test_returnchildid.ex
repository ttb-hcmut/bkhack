defmodule ReturnChildID do
  def getChildID(parent\\"0",offset\\0,limit\\10) do
    Enum.map((offset)..min(offset+limit,9), fn x -> parent <> Integer.to_string(x) end)
    |>Enum.to_list()
    |>IO.inspect()
  end
  def getChildComments(parent\\"0",offset\\0,limit\\10) do
    Enum.map(getChildID(parent,offset,limit), fn y -> %{id: y, content: "Comment " <> y <> ", child of " <> parent <> "."} end)
  end
end
