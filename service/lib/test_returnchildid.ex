defmodule ReturnChildID do
  def getChildID(parent\\"0",offset\\0,limit\\10) do
    Enum.map((offset)..min(offset+limit-1,9), fn x -> parent <> Integer.to_string(x) end)
    |>Enum.to_list()
    |>IO.inspect()
  end
  def getChildComments(parent\\"0",offset\\0,limit\\10) do
    Enum.map(getChildID(parent,offset,limit), fn y ->
      %{
        id: y,
        text: "Comment " <> y <> ", child of " <> parent <> ".",
        # unique to the user, maybe a table keeping track of ratings idk worry later
        user_rating: Integer.to_string(if rem(31 * String.to_integer(y), 13) == 0, do: -1, else: (if rem(31 * String.to_integer(y), 13) == 1, do: 1, else: 0)),
        rating: Integer.to_string(rem(13 * String.to_integer(y), 69)),
        timestamp: Integer.to_string(System.os_time(:second)- 3600*24*7 + rem( 1300 * String.to_integer(y),3600*24*7)),
        post_vers: Integer.to_string(rem(String.to_integer(y), 7)),
        author_name: "@AuthorOf" <> y,
        author_id: "aido" <> y,
        author_role: (if rem(String.to_integer(y), 13) == 0, do: "prof", else: "student"),
        author_rep: Integer.to_string(rem(17 * String.to_integer(y), 420))
      }
    end)
  end
end
