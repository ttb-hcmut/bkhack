type 'a code =
  { code_parse :
      time:time -> peek:(unit -> char) -> advance:(unit -> unit) -> unit -> ('a, string) result }

and time =
  { time_save : unit -> snapshot
  ; time_restore : snapshot -> unit
  }

and snapshot =
  { snapshot_i : int }

let advance n =
  let code_parse ~time:_ ~peek:_ ~advance () =
    for _ = 0 to (n-1) do
      advance ()
    done; Result.ok () in
  { code_parse }

let take_while pred =
  let rec code_parse' ~time ~peek ~advance () =
    let ch = peek () in
    if not @@ pred ch then [] else
    (advance (); ch :: (code_parse' ~time ~peek ~advance ())) in
  let code_parse ~time ~peek ~advance () =
    let char_arr = code_parse' ~time ~peek ~advance () in
    let b = Buffer.create (List.length char_arr) in
    List.iter (Buffer.add_char b) char_arr;
    Result.ok @@ Buffer.contents b in
  { code_parse }

let take_while1 pred =
  let rec code_parse' ~time ~peek ~advance () =
    let ch = peek () in
    if pred ch then (advance (); ch :: (code_parse' ~time ~peek ~advance ()))
    else [] in
  let code_parse ~time ~peek ~advance () =
    let char_arr = code_parse' ~time ~peek ~advance () in
    (* TODO(kinten) prove that size is >= 0 *)
    if List.length char_arr = 0 then
      Result.error "take_while1 string length is 0"
    else begin
      let b = Buffer.create (List.length char_arr) in
      List.iter (Buffer.add_char b) char_arr;
      Result.ok @@ Buffer.contents b
    end in
  { code_parse }

let lift f t =
  let code_parse ~time ~peek ~advance () =
    Result.map f @@ t.code_parse ~time ~peek ~advance () in
  { code_parse }

let lift2 f t1 t2 =
  let code_parse ~time ~peek ~advance () =
    let x1 = t1.code_parse ~time ~peek ~advance () in
    Result.bind x1 @@ fun x1 ->
    let x2 = t2.code_parse ~time ~peek ~advance () in
    Result.bind x2 @@ fun x2 ->
    Result.ok @@ f x1 x2 in
  { code_parse }

let map t f =
  let code_parse ~time ~peek ~advance () =
    Result.map f @@ t.code_parse ~time ~peek ~advance () in
  { code_parse }

let fix f =
  let last = ref None in
  let rec_ =
    let code_parse ~time ~peek ~advance () =
      let x = !last |> Option.get in
      x.code_parse ~time ~peek ~advance () in
    { code_parse } in
  let x = f rec_ in
  last := Some x; x

let either a b =
  let code_parse ~time ~peek ~advance () =
    let m = time.time_save () in
    let a1 = a.code_parse ~time ~peek ~advance () in
    match a1 with Result.Error e ->
      (* TODO(kinten) trace error? *) ignore e;
      time.time_restore m;
      b.code_parse ~time ~peek ~advance ()
    | Result.Ok a1' ->
    (* TODO(kinten) peek success? *) ignore a1';
    a1
    in
  { code_parse }

let seq a b = lift2 (fun a b -> (a, b)) a b

let seqr a b = lift2 (fun () x -> x) a b

let seql a b = lift2 (fun x () -> x) a b

let discard_first a b = lift2 (fun _a b -> b) a b

let discard_second a b = lift2 (fun a _b -> a) a b

let always_ignore (x: 't code) =
  lift (fun _ -> ()) x

module Syntax_0 =
  struct

  let ( or ), ( <|> ) = either, either

  and ( *. ), ( +> ), ( <+ ) = seq, seqr, seql

  and ( <* ), ( *> ) = discard_second, discard_first

  and ( >>| ), ( $ ) = map, map

  and ( <$> ) = lift

  and ( ~- ) = always_ignore

  end

let char ch =
  let code_parse ~time:_ ~peek ~advance () =
    let ch' = peek () in
    advance ();
    if not @@ Char.equal ch ch' then
      Result.error (Printf.sprintf "char: did not match: '%c' != '%c'" ch ch')
    else
      Result.ok ch in
  { code_parse }

let charset template =
  let code_parse ~time:_ ~peek ~advance () =
    let ch = peek () in
    advance ();
    if not @@ String.contains template ch then
      Result.error (Printf.sprintf "char: did not match: '%c' is not in charset '%s'" ch template)
    else Result.ok ch in
  { code_parse }

let peek_char =
  let code_parse ~time ~peek ~advance () =
    let m = time.time_save () in
    try let ch = peek () in advance (); ignore (peek ()); time.time_restore m; Result.ok @@ Some ch
    with _ -> time.time_restore m; Result.ok None
    in
  { code_parse }

let peek_char_fail =
  let code_parse ~time ~peek ~advance () =
    let m = time.time_save () in
    try let ch = peek () in advance (); ignore (peek ()); time.time_restore m; Result.ok ch
    with _ -> time.time_restore m; Result.error "peek_char failed"
    in
  { code_parse }

let end_of_input = lift (fun _ -> ()) @@ char '\x1B'

let parse_string ~consume:(_consume:[`All | `Prefix]) (t: 'a code) : string -> ('a, string) result =
  fun s ->
  let s = String.to_seq (s ^ "\x1B") |> Array.of_seq in
  let i = ref 0 in
  let peek () = Array.get s !i in
  let advance () = i := !i + 1 in
  let time =
    let time_save () = { snapshot_i = !i } in
    let time_restore sn = i := sn.snapshot_i in
    { time_save; time_restore } in
  t.code_parse ~time ~peek ~advance ()

(** {0:monad Monadic extensions} *)

let bind t f =
  let code_parse ~time ~peek ~advance () =
    t.code_parse ~time ~peek ~advance ()
    |> function Result.Ok x ->
      (f x).code_parse ~time ~peek ~advance ()
    | Result.Error e -> Result.Error e in
  { code_parse }

let product a b =
  let code_parse ~time ~peek ~advance () =
    let a' = a.code_parse ~time ~peek ~advance () in
    Result.bind a' @@ fun a' ->
    let b' = b.code_parse ~time ~peek ~advance () in
    Result.bind b' @@ fun b' ->
    Result.ok (a', b') in
  { code_parse }

let return x =
  let code_parse ~time:_ ~peek:_ ~advance:_ () =
    Result.ok x in
  { code_parse }

let fail msg =
  let code_parse ~time:_ ~peek:_ ~advance:_ () =
    Result.error msg in
  { code_parse }

module Syntax =
  struct include Syntax_0

  let ( let* ) = bind
  and ( and* ) = product

  end
