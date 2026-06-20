let __re__group__get i groups = Re.Group.get groups i

let get_padding =
  let pattern =
    let open Re in
    (seq [bos; group (space |> rep |> greedy); notnl |> rep |> shortest; eos])
    |> compile in
  Re.exec pattern
  %> __re__group__get 1

let undo_relative_indentation ~min_padding expect_str = if min_padding <= 0 then expect_str else begin
  expect_str
  |> String.split_on_char '\n'
  |> List.fold_left (fun acc x ->
    if String.for_all (function ' ' -> true | _ -> false) x then x :: acc else
    String.sub x min_padding (String.length x - min_padding) :: acc
  ) []
  |> List.rev
  |> String.concat "\n"
end

let min_padding expect_str = if String.for_all (fun x -> not (x = '\n')) expect_str then 0 else
  expect_str
  |> String.split_on_char '\n'
  |> List.fold_left (fun acc x ->
    if String.for_all (function ' ' -> true | _ -> false) x then acc else
    let n = get_padding x |> String.length in
    if n < acc then n else acc
  ) Int.max_int
