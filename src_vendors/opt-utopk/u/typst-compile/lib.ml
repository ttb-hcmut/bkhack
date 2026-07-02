let replaces ls =
  let ls = ls |> List.map(fun (pat, replacewith) -> (Re.compile @@ pat, replacewith)) in
  fun target ->
  List.fold_left (fun acc (pat, replacewith) ->
    let f _ = replacewith in
    Re.replace ~all:true ~f pat acc
  ) target ls

let process = 
  let process_text =
    replaces [
      Re.(seq [char '\\'; char '\n'; str "  "]), "\n\n";
      Re.(seq [char '\n'; char '-' ]) , "-";
      Re.(seq [char '\n'; str  "--"]) , "--";
      Re.(seq [str  "--"; char '\n']) , "--";
      Re.(seq [char '\n'; char ';' ]) , ";";
      Re.(seq [char '\n'; char ':' ]) , ":";
      Re.(seq [char '\n'; char ',' ]) , ",";
      Re.(seq [char '\n'; char '.' ]) , ".";
    ]
  and header s = {|#import "/article"
#show: article.doc
|} ^ s in
  fun ~article_at_root s -> (
    assert article_at_root;
    s |> process_text |> header
  )
