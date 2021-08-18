let test_parse0 () =
  let fn = "dumps/2020-12-02T110016.post" in
  let st = Unix.stat fn in
  Assert2.equals_int "uhu" 235570 st.st_size;
  let ic = open_in_gen [ Open_rdonly; Open_binary ] 0o222 fn in
  match Lib.Rfc2388.process ic stdout "/dev/null" with
  (* | Ok { Part.name = n; filename = None; mime = None } ->
     Assert2.equals_string "uhu" "title" n
  *)
  | _ -> assert true

let () =
  Unix.chdir "../../../test/";
  test_parse0 ()
