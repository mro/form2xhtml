#
# https://github.com/ocaml/dune/tree/master/example/sample-projects/hello_world
# via https://stackoverflow.com/a/54712669
#
.PHONY: all build clean test install uninstall doc examples

build:
	@echo "let git_sha = \""`git rev-parse --short HEAD`"\"" > lib/version.ml
	@echo "let date = \""`date +'%FT%T%z'`"\""              >> lib/version.ml
	dune build bin/form2xml.exe

all: build

test/assert.ml:
	curl --location --output $@ https://raw.githubusercontent.com/benjenkinsv95/ocaml-unit-testing-helpers/master/assert.ml

test: test/assert.ml
	dune runtest

examples:
	dune build @examples

install:
	dune install

uninstall:
	dune uninstall

doc:
	dune build @doc

clean:
	rm -rf _build *.install

