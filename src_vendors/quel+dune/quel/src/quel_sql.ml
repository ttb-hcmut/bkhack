(* The GenSQL interpreter for SQL translations *)

open Quel_sym

module GenSQL = struct

  (* Normal form *)
  type 'a row = 'a
  type 'a field = 'a
  type 'a term =
    | IntC    : int -> int term
    | BoolC   : bool -> bool term
    | StringC : string -> string term
    | FloatC  : float -> float term
    | UnOp    : (string * 'a term) -> 'b term
    | BinOp   : (string * 'a term * 'a term) -> 'b term
    | If      : (bool term * 'a term * 'a term) -> 'a term
    | Var     : string -> 'a term
    | For      : (unit -> 'a list term) * string * 'b list term -> 'b list term
    | Where    : bool term * (unit -> 'a list term) -> 'a list term
    | Yield    : 'a term -> 'a list term
    | Limit    : int * int * (unit -> 'a list term) -> 'a list term
    | Exists   : 'a list term -> bool term
    | Nil      : unit -> 'a list term
    | UnionAll : ('a list term * 'a list term) -> 'a list term
    | Table    : (string * 'a list) -> 'a list term
    | Record   : 'a row term -> 'b term
    | Field    : (string * 'a term) -> 'a field term
    | RowOne   : ('a field term * unit) -> ('a * unit) row term
    | Row      : ('a field term * 'b row term) -> ('a * 'b) row term
    | Proj     : ('r term * string) -> 'f term
    | Ill      : 'a term  (* ill-formed terms *)

  (* Representation type *)
  type varcount = int
  type 'a repr  = varcount -> 'a term

  (* Target SQL fragment *)
  type table = string
  type var   = string
  type field_name = string

  type sql_query = (* Q, R *)
    | SUnionAll of sql_comp list (* sql_query * sql_query *)  (* Q union all R *)
  and sql_comp =   (* S *)
    (* select s1,...,sn from t1 as x1,...,tn as xn where e limit i offset j *)
    | SSelect of sql_select * sql_table * sql_exp * (int * int) option
  and sql_table =
    | SFrom of (table * var) list
  and sql_select = (* s *)
      SList of (sql_exp * field_name) list           (* e as l *)
    | SAll of string (* x.* *)
  and sql_exp =    (* e *)
    | SInt of int
    | SBool of bool
    | SString of string
    | SFloat of float
    | SField of sql_exp * field_name       (* e AS l *)
    | SProj of var * field_name            (* x.l *)
    | SCase of sql_exp * sql_exp * sql_exp (* case when e then e1 else e2 end *)
    | SExists of sql_query                 (* exists(Q) *)
    | SBinOp of string * sql_exp * sql_exp    (* op(e1,e2) *)
    | SUnOp of string * sql_exp               (* op(e) *)

  let varnames = "xyzuvw"
  let varname = function
    | i when i < String.length varnames ->
      String.make 1 @@ varnames.[i]
    | i -> "x" ^ string_of_int i



  let int (n:int)      = fun v -> IntC n
  let bool(b:bool)     = fun v -> BoolC b
  let string(s:string) = fun v -> StringC s
  let float(f:float)   = fun v -> FloatC f

  let (+%)  x y = fun v -> BinOp("+", x v, y v)
  let (-%)  x y = fun v -> BinOp("-", x v, y v)
  let ( *%) x y = fun v -> BinOp("*", x v, y v)
  let (/%)  x y = fun v -> BinOp("/", x v, y v)

  let (+%.)  x y = fun v -> BinOp("+", x v, y v)
  let (-%.)  x y = fun v -> BinOp("-", x v, y v)
  let ( *%.) x y = fun v -> BinOp("*", x v, y v)
  let (/%.)  x y = fun v -> BinOp("/", x v, y v)

  let (<%) x y = fun v -> BinOp("<", x v, y v)
  let (>%) x y = fun v -> BinOp(">", x v, y v)
  let (=%) x y = fun v -> BinOp("=", x v, y v)

  let (>%.) x y = fun v -> BinOp(">", x v, y v)
  let (<%.) x y = fun v -> BinOp("<", x v, y v)
  let (=%.) x y = fun v -> BinOp("=", x v, y v)

  let (>&) x y = fun v -> BinOp(">", x v, y v)
  let (<&) x y = fun v -> BinOp("<", x v, y v)
  let (=&) x y = fun v -> BinOp("=", x v, y v)

  let (>@) x y = fun v -> BinOp(">", x v, y v)
  let (<@) x y = fun v -> BinOp("<", x v, y v)
  let (=@) x y = fun v -> BinOp("=", x v, y v)

  let (&%) x y = fun v -> BinOp("AND", x v, y v)
  let (|%) x y = fun v -> BinOp("OR",  x v, y v)
  let (!%) x   = fun v -> UnOp("NOT",  x v)

  let if_ e e1 e2 = fun v -> If(e v, (e1 ()) v, (e2 ()) v)
  (* lam and app has been reduced in normalizations *)
  let lam f       = fun v -> Ill
  let app e1 e2   = fun v -> Ill

  (* List *)
  let foreach src body = fun v ->
    let vn = varname v in
    For((fun () -> src () v), vn, (body (fun v -> Var vn) (v+1)))
  let where test body  = fun v -> Where(test v, (fun () -> (body () v)))
  let yield x  = fun v -> Yield (x v)
  let limit count offset body = fun v -> Limit (count, offset, (fun () -> (body () v)))
  let (@%) x y = fun v -> UnionAll (x v,y v)
  let nil ()   = fun v -> Nil ()
  let exists x = fun v -> Exists(x v)


  (*
   * Auxiliary functions that build a term in GenSQL
   *)
  (* projection *)
  let (%.) r l = fun v ->
    Proj(r v, l)

  (* field; field_name=field_value *)
  let (%:) : string -> 'a repr -> 'a field repr = fun label x -> fun v ->
    Field(label, x v)

  (* construct primitive row *)
  let row1 : 'a field repr -> ('a * unit) row repr = fun f -> fun v ->
    RowOne(f v, ())
  (* construct row *)
  let ( %* ) : 'a field repr -> 'b row repr -> ('a * 'b) row repr = fun f row -> fun v ->
    Row(f v, row v)

  (* record *)
  let record : 'a row repr -> 'b repr = fun row -> fun v ->
    Record(row v)


  let table (s,t) = fun v -> Table(s,t)


  (* SQL translations
     Convert from a normalized form to a value of the sql_query type
     If the normalized term is not normal form, it will fail.
  *)
  let rec to_sql exp =
    let rec query : type a. a term -> sql_query = function
      | UnionAll(e1,e2) ->
	 begin
	   match query e1, query e2 with
	     SUnionAll(e1'), SUnionAll(e2') -> SUnionAll(e1' @ e2')
	 end
      | Nil () -> SUnionAll([])
      | f      -> SUnionAll([comp f])
    (* comprehension normal forms *)
    (* [[foreach (fun () -> table s) (fun x -> Q)]] =
       SELECT e AS l... FROM s AS x..., t AS y WHERE e
         where [[Q]] = (SELECT e as l... FROM t as y... WHERE e *)
    and comp : type a. a term -> sql_comp = function
      | For(t,vn,b) -> begin
          match t () with
          | Table(tn, _) -> begin
              match comp b with
	        SSelect(s,SFrom ts,e,limit) -> SSelect(s,(SFrom ((tn,vn)::ts)),e,limit)
            end
          | _ -> failwith "Illegal form: comp"
        end
      | z -> comp_body z
    (* comprehension bodies *)
    and comp_body : type a .a term -> sql_comp =
      let conjoin e1 e2 = SBinOp("AND", e1, e2) in
      function
      | Where(t,b) ->
	 begin
	   match comp_body (b ()) with
	     SSelect(s,ts,t',limit) -> SSelect(s, ts, conjoin t' (base_exp t), limit)
	 end
      | Table(t,_) -> SSelect(SAll(t), SFrom [(t,t)], SBool true, None)
      | Yield(r)   -> SSelect(row_form r, SFrom [], SBool true, None)
      | Limit(count, offset, b) ->
  begin
    match comp_body (b ()) with
      SSelect(s,ts,t,_) -> SSelect(s, ts, t, Some (count, offset))
  end
      | _ -> failwith "Illegal form: comp_body"
    (* row form
       [[<l=B> = [[B]] as l]] *)
    and row_form : type a. a term -> sql_select =
      let join e1 e2 =
        match (e1, e2) with
        | (SList(e1'),SList(e2')) -> SList(e1' @ e2')
        | _ -> failwith "Illegal form: row"
      in function
      | Field(name, e) -> SList([(base_exp e, name)])
      | RowOne(e1, ()) -> row_form e1
      | Row(e1, e2)    -> join (row_form e1) (row_form e2)
      | Record(row)    -> row_form row
      | Var x          -> SAll(x)
      | _ -> failwith "Illegal form: row_form"
    (* base expressions *)
    and base_exp : type a. a term -> sql_exp = function
      | If(e,e1,e2) -> SCase(base_exp e, base_exp e1, base_exp e2)
      | Exists e    -> SExists(query e)
      | BinOp(op,e1,e2) -> SBinOp(op, base_exp e1, base_exp e2)
      | UnOp(op,e)      -> SUnOp(op, base_exp e)
      | Proj(Var x, l)  -> SProj(x,l)
      | IntC(n)     -> SInt(n)
      | BoolC(b)    -> SBool(b)
      | StringC(s)  -> SString(s)
      | FloatC(f)   -> SFloat(f)
      | _ -> failwith "Illegal form: base_exp"
    in query exp

  (* a value of the sql_query type to an SQL string *)
  let paren x = "(" ^ x ^ ")"
  let to_str q =
    let rec to_query (SUnionAll qs) = String.concat " UNION ALL " (List.map to_comp qs)
    and to_comp (SSelect(s,t,e,limit)) =   "SELECT " ^ to_select s
				   ^ " FROM "  ^ to_from t
				   ^ " WHERE " ^ to_exp e
           ^ ( match limit with None -> ""
             | Some (count, offset) -> " LIMIT " ^ string_of_int count ^ " OFFSET " ^ string_of_int offset )
    and to_select = function
      | SList(cols) -> String.concat ", " (List.map (fun (e,x) -> to_exp e ^ " AS " ^ x) cols)
      | SAll(x)     -> x ^ ".*"
    and to_from (SFrom ts) = String.concat ", " (List.map (fun (t,v) -> t ^ " AS " ^ v) ts)
    and to_exp = function
      | SInt(n)     -> string_of_int n
      | SBool(b)    -> string_of_bool b
      | SString(s)  -> "'" ^ s ^ "'"
      | SFloat(f)   -> string_of_float f
      | SProj(x,l)  -> x ^ "." ^ l
      | SField(e,l) -> (to_exp e) ^ " AS " ^ l
      | SExists(q)  -> paren ("EXISTS " ^ paren (to_query q))
      | SBinOp(op, e1, e2) -> to_binop op (to_exp e1) (to_exp e2)
      | SUnOp(op, e) -> to_unop op (to_exp e)
      | SCase(e,e1,e2) -> paren ("CASE WHEN " ^ to_exp e ^ " THEN " ^ to_exp e1 ^ " ELSE " ^ to_exp e2 ^ " END")
    and to_binop op s1 s2 =
      match op with
      | "OR" -> "(" ^ s1 ^ " " ^ op ^ " " ^ s2 ^ ")"
      | _    -> s1 ^ " " ^ op ^ " " ^ s2
    and to_unop op s = op ^ " " ^ s
    in to_query q

  (* observation *)
  type 'a obs   = string
  let observe x = to_str @@ to_sql (x () 0)
  (* checking norma form *)
  let check_NF x = try let _ = to_sql (x () 0) in true with _ -> false
end
