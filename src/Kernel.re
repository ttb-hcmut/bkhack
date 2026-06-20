let __re__group__get = (i, groups) => Re.Group.get(groups, i);

let get_padding = {
  let pattern =
    Re.(
      seq([
        bos,
        group(space |> rep |> greedy),
        notnl |> rep |> shortest,
        eos,
      ])
      |> compile
    );
  Re.exec(pattern) %> __re__group__get(1);
};

let undo_relative_indentation = (~min_padding, expect_str) =>
  if (min_padding <= 0) {
    expect_str;
  } else {
    expect_str
    |> String.split_on_char('\n')
    |> List.fold_left(
         (acc, x) =>
           if (String.for_all(
                 fun
                 | ' ' => true
                 | _ => false,
                 x,
               )) {
             [x, ...acc];
           } else {
             [
               String.sub(x, min_padding, String.length(x) - min_padding),
               ...acc,
             ];
           },
         [],
       )
    |> List.rev
    |> String.concat("\n");
  };

let min_padding = expect_str =>
  if (String.for_all(x => !(x == '\n'), expect_str)) {
    0;
  } else {
    expect_str
    |> String.split_on_char('\n')
    |> List.fold_left(
         (acc, x) =>
           if (String.for_all(
                 fun
                 | ' ' => true
                 | _ => false,
                 x,
               )) {
             acc;
           } else {
             let n = get_padding(x) |> String.length;
             if (n < acc) {
               n;
             } else {
               acc;
             };
           },
         Int.max_int,
       );
  };
