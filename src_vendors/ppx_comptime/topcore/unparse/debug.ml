let toplevel_phrase x =
  let buffer = Buffer.create 100 in
  let noformatter = Format.formatter_of_buffer buffer in
  Printast.top_phrase noformatter x;
  Buffer.contents buffer

let expression x =
  let buffer = Buffer.create 100 in
  let noformatter = Format.formatter_of_buffer buffer in
  Printast.expression 5 noformatter x;
  Buffer.contents buffer
