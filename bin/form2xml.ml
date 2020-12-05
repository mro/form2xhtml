let err i msgs =
  let exe = Filename.basename Sys.executable_name in
  msgs |> List.cons exe |> String.concat ": " |> prerr_endline;
  i

let print_version () =
  let exe = Filename.basename Sys.executable_name in
  Printf.printf "%s: https://mro.name/%s/v%s, built: %s\n" exe "form2xml"
    Lib.Version.git_sha Lib.Version.date;
  0

let print_help () =
  let msg =
    "Convert HTTP multipart/form-data RFC 2388 POST dumps into xml for e.g. \
     Atom RFC 4287.\n\n\
     See\n\n\
     * https://tools.ietf.org/html/rfc2388\n\
     * https://ec.haxx.se/http/http-multipart\n\
     * https://tools.ietf.org/html/rfc4287\n\n\
     SYNOPSIS\n\n\
     $ form2xml -h\n\
     $ form2xml -v\n\
     $ form2xml [enclosure prefix] < source.dump > target.xml\n\
     $ form2xml /dev/null < source.dump > target.xml\n\n"
  in
  Printf.printf "%s\n" msg;
  0

let () =
  ( match Sys.argv |> Array.to_list |> List.tl with
  | [ "-h" ] | [ "--help" ] -> print_help ()
  | [ "-v" ] | [ "--version" ] -> print_version ()
  | [ pre ] ->
      pre |> Lib.Rfc2388.process stdin;
      0
  | [] ->
      "./" |> Lib.Rfc2388.process stdin;
      0
  | _ -> err 2 [ "get help with -h" ] )
  |> exit
