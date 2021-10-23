#!/bin/sh
# https://mro.name/form2xhtml
#
cd "$(dirname "${0}")" || exit 1

make clean
make || exit 1

readonly name="form2xhtml"
readonly ver="0.1"

readonly src="_build/default/bin/${name}.exe"

git_sha="$(sed -En '/git_sha/s/^.+"([0-9a-f]+)"/\1/gp' < lib/version.ml)"
dst="${name}-v${ver}+${git_sha}-$(uname -s)-$(uname -m)"
readonly git_sha dst

chmod u+w "${src}"
strip "${src}"
file "${src}"

readonly dir="/var/www/vhosts/dev.mro.name/pages/${name}"
ssh c1 mkdir -p "${dir}" \
  && rsync -avPz "${src}" c1:"${dir}/${dst}" \
  && ssh c1 ls -Al "${dir}/${dst}" \
  && exit 0

echo rsync -avPz "$(pwd)/${src}" c1:"${dir}/${dst}"
exit 1

