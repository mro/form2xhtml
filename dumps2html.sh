#!/bin/sh
form2xml --help >/dev/null || { echo "Install https://mro.name/form2xhtml" 1>&2 && exit 1;  }

[ -r "${1}" ] || {
cat 1>&2 <<EOF
Give me dumped posts as files on the commandline and I'll make them html again
and store them in the current directory.
EOF
  exit 2
}

while [ -r "${1}" ]
do
  src="${1}"
  shift
  dst="$(basename "${src}").html"

  form2xml /dev/null < "${src}" | xmllint --format --nocdata --nonet --encode utf8 - > "${dst}"
  echo "${dst}"
done

# check if there's leftovers?
