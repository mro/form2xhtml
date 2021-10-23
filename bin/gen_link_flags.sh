#!/bin/sh
# https://discuss.ocaml.org/t/dune-how-to-link-statically-on-linux-not-on-others/8537/4?u=mro

case "$(uname -s)" in
  Darwin)
    # do not link statically on macos.
    echo '()'
    ;;
  *)
    echo '(-ccopt "-static")'
    ;;
esac

