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

  (* values are tokens, still *)
  let kv =
    conv
      (function a, `Left x -> (a, x) | a, `Right x -> (a, x))
      (function a, x -> (a, `Left x) (* prefer quoted form *))
      ( pcre "[^= \r\n]+"
      <&> char '=' *> (quot *> pcre "[^\"\r\n]+" <* quot <|> pcre "[^\r\n]+") )

  let kv_line =
    compile
      ( start *> pcre "[^: \r\n]+"
      <&> str ": " *> pcre "[^; \r\n]+"
      <&> list (str "; " *> kv)
      <* cr <* stop )
end

(** a tuple, followed by a list of tuples *)
let parse_line str = str |> Tyre.exec P.kv_line

let copy_channel boundary ic oc =
  let blen = boundary |> String.length in
  let rec cp back =
    match blen = back with
    | true -> oc
    | false -> (
        let ch = ic |> input_char in
        match ch = boundary.[back] with
        | false ->
            output_substring oc boundary 0 back;
            ch |> output_char oc;
            cp 0
        | true -> cp (1 + back) )
  in
  cp 0

type meta = {
  name : string;
  filename : string option;
  mime : string option;
  boundary : string option;
}

let process ic prefix =
  let rec parse_header r' =
    match r' with
    | Error _ ->
        Printf.eprintf "error: cannot parse part header\n";
        r'
    | Ok r -> (
        let lin = ic |> input_line in
        match lin |> parse_line with
        | Error (`NoMatch (_, "\r")) ->
            (* despite the scary name this is successful termination *)
            Ok r
        | Error e ->
            Printf.eprintf "error: cannot parse part header line '%s'\n" lin;
            Error e
        | Ok (("Content-Disposition", "form-data"), [ ("name", n) ]) ->
            parse_header (Ok { r with name = n })
        | Ok
            ( ("Content-Disposition", "form-data"),
              [ ("name", n); ("filename", fn) ] ) ->
            parse_header (Ok { r with name = n; filename = Some fn })
        | Ok (("Content-Type", mim), [ ("boundary", bo) ]) ->
            parse_header (Ok { r with mime = Some mim; boundary = Some bo })
        | Ok (("Content-Type", mim), []) ->
            parse_header (Ok { r with mime = Some mim })
        | Ok _ ->
            (* Printf.eprintf "warning: ignored header '%s'\n" f; *)
            parse_header r' )
  and empt = { name = ""; filename = None; mime = None; boundary = None } in
  match Ok empt |> parse_header with
  | Ok
      {
        name = "";
        filename = None;
        mime = Some "multipart/form-data";
        boundary = Some bou';
      } ->
      let copy_file bound ic fn =
        ( match prefix with
        | "/dev/null" -> open_out prefix
        | _ ->
            prefix ^ fn
            |> open_out_gen
                 [ Open_wronly; Open_creat; Open_excl; Open_binary ]
                 0o664 )
        |> copy_channel bound ic |> close_out
      (* leave cleanup after exceptions to the OS *)
      and boundry = "\r\n" ^ "--" ^ bou' in
      let rec scan_part depth =
        ( match parse_header (Ok empt) with
        | Ok { name = n; filename = None; mime = _; boundary = _ } ->
            (* CDATA isn't a solution for escaping but rather a mitigation.
             * Works until the payload contains the literal ']]>' *)
            Printf.printf "  <textarea name=\"%s\"><![CDATA[" n;
            let _ = copy_channel boundry ic stdout in
            Printf.printf "]]></textarea>\n"
        | Ok { name = n; filename = Some fn; mime = Some mim; boundary = _ } ->
            Printf.printf
              "  <input type=\"file\" mime=\"%s\" name=\"%s\" value=\"%s\"/>\n"
              mim n fn;
            copy_file boundry ic fn
        | _ -> Printf.eprintf "error: unexpected part header\n" );
        match ic |> input_line with
        | "\r" -> scan_part (depth + 1)
        | "--\r" -> ()
        | _ -> Printf.eprintf "error: unexpected part gutter\n"
      in
      let _ = ic |> input_line (* TODO check if boundary *) in
      Printf.printf "<form>\n";
      scan_part 0;
      Printf.printf "</form>\n"
  | _ -> Printf.eprintf "error: Not a boundary\n"
