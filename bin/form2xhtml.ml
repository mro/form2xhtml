let err i msgs =
  let exe = Filename.basename Sys.executable_name in
  msgs |> List.cons exe |> String.concat ": " |> prerr_endline;
  i

let print_version oc =
  let exe = Filename.basename Sys.executable_name in
  Printf.fprintf oc "%s: https://mro.name/%s/v%s, built: %s\n" exe "form2xhtml"
    Lib.Version.git_sha Lib.Version.date;
  0

let print_help oc =
  Printf.fprintf oc "%s\n"
    "Convert a HTTP multipart/form-data RFC 2388 POST dump into a xhtml form.\n\n\
     See\n\n\
     * https://tools.ietf.org/html/rfc2388\n\
     * https://ec.haxx.se/http/http-multipart\n\
     * https://tools.ietf.org/html/rfc4287\n\n\
     SYNOPSIS\n\n\
     $ form2xhtml -h\n\
     $ form2xhtml -V\n\
     $ form2xhtml enclosure_prefix < source.dump > target.html\n\
     $ form2xhtml ./ < source.dump > target.html\n\
     $ form2xhtml /dev/null < source.dump > target.html\n";
  0

let () =
  (match Sys.argv |> Array.to_list |> List.tl with
  | [ "-h" ] | [ "--help" ] -> print_help stdout
  | [ "-V" ] | [ "--version" ] -> print_version stdout
  | [ pre ] ->
      pre |> Lib.Rfc2388.process stdin stdout;
      0
  | _ -> err 2 [ "get help with -h" ])
  |> exit
