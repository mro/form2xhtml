(* 
 * Primitive implementation of a small subset of RFC 2388.
 *
 * Prepare dumps of dump.cgi for e.g. form2atom.xslt.
 *
 * Proper implementations are e.g.
 * - https://opam.ocaml.org/packages/multipart_form/
 * - https://opam.ocaml.org/packages/multipart-form-data/
 *)

module P = struct
  (* https://gabriel.radanne.net/papers/tyre/tyre_paper.pdf#page=9 *)
  open Tyre

  let quot = char '"'

  let cr = char '\r'

  let boundary' = start *> str "--" *> pcre "[^ \r\n]+" <* cr *> stop

  let boundary = compile boundary'

  (* right values are tokens, still *)
  let kv =
    conv
      (fun (a, b) -> (a, b))
      (fun (a, b) -> (a, b))
      (pcre "[^= \r\n]+" <&> char '=' *> quot *> pcre "[^\"\r\n]+" <* quot)

  let kv_line =
    compile
      ( start *> pcre "[^: \r\n]+"
      <&> str ": " *> pcre "[^; \r\n]+"
      <&> list (str "; " *> kv)
      <* cr <* stop )
end

let parse_boundary str = str |> Tyre.exec P.boundary

(** a tuple, followed by a list of tuples *)
let parse_line str = str |> Tyre.exec P.kv_line

let copy_channel boundary ic oc =
  let blen = String.length boundary in
  let rec cp back =
    match blen = back with
    | true -> oc
    | false -> (
        let ch = ic |> input_char in
        match ch = boundary.[back] with
        | false ->
            (* hope the boundary has no xml entities *)
            output_substring oc boundary 0 back;
            ( match ch with
            (* do not escape for now
               | '>' -> "&gt;" |> output_string oc
               | '<' -> "&lt;" |> output_string oc
               | '&' -> "&amp;" |> output_string oc
               | '"' -> "&quot;" |> output_string oc
               | '\'' -> "&apos;" |> output_string oc
            *)
            | ch -> ch |> output_char oc );
            cp 0
        | true -> cp (1 + back) )
  in
  cp 0

type meta = { name : string; filename : string option; mime : string option }

let process ic prefix =
  match ic |> input_line |> parse_boundary with
  | Ok bou' ->
      let boundary = "\r\n" ^ "--" ^ bou' in
      let rec parse_header r' =
        match r' with
        | Error _ ->
            Printf.eprintf "error: cannot parse part header";
            r'
        | Ok r -> (
            match ic |> input_line |> parse_line with
            | Error (`NoMatch (_, "\r")) ->
                (* despite the scary name this is successful termination *)
                Ok r
            | Ok (("Content-Disposition", "form-data"), [ ("name", n) ]) ->
                parse_header (Ok { r with name = n })
            | Ok
                ( ("Content-Disposition", "form-data"),
                  [ ("name", n); ("filename", fn) ] ) ->
                parse_header (Ok { r with name = n; filename = Some fn })
            | Ok (("Content-Type", mim), []) ->
                parse_header (Ok { r with mime = Some mim })
            | _ ->
                Printf.eprintf "error: cannot parse part header line";
                r' )
      in
      let copy_file fn =
        prefix ^ fn
        |> open_out_gen
             [ Open_wronly; Open_creat; Open_excl; Open_binary ]
             0o664
        |> copy_channel boundary ic |> close_out
        (* leave cleanup after exceptions to the OS *)
      in
      let rec scan_part depth =
        ( match
            parse_header (Ok { name = ""; filename = None; mime = None })
          with
        | Ok { name = n; filename = Some fn; mime = Some mim } ->
            Printf.printf
              "  <input type=\"file\" mime=\"%s\" name=\"%s\" value=\"%s\"/>\n"
              mim n fn;
            copy_file fn
        | Ok { name = n; filename = None; mime = None } ->
            Printf.printf "  <textarea name=\"%s\">" n;
            let _ = copy_channel boundary ic stdout in
            Printf.printf "</textarea>\n"
        | _ -> Printf.eprintf "error: unexpected part header" );
        match ic |> input_line with
        | "\r" -> scan_part (depth + 1)
        | "--\r" -> ()
        | _ -> Printf.eprintf "error: unexpected part gutter"
      in
      Printf.printf "<form>\n";
      scan_part 0;
      Printf.printf "</form>\n"
  | Error _ -> Printf.eprintf "error: Not a boundary"
