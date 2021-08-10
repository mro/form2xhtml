#!/bin/sh
# dump HTTP post requests. Nice for off-site, static website feedback.
#
# Use e.g. https://mro.name/form2xhtml to process them.

# where do you want to dump to?
cd "/var/spool/form2xml/dumps/" || exit 1
# ensure existing maildir structure
cd "tmp" || exit 1
cd "../new" || exit 1
cd ".." || exit 1

if [ "$(ls new/*.post | wc -l)" -gt 100 ] ; then
  cat <<EndOfMessage
Status: 302 Found
Location: overflow.html

Overflowing, traffic jam straight up ahead!
EndOfMessage
  exit 2
fi

# https://stackoverflow.com/a/52363117
[ "${CONTENT_LENGTH}" -gt 0 ] || exit 2

dst="$(date +%FT%H%M%S).post"
{
  printf "%s: %s\r\n" "Content-Type" "${CONTENT_TYPE}"
  printf "%s: %s\r\n" "Content-Length" "${CONTENT_LENGTH}"
  # printf "%s: \"%s\"\r\n" "User-Agent" "${HTTP_USER_AGENT}"
  printf "%s: %s\r\n" "Remote-Address" "${REMOTE_ADDR}"
  printf "\r\n"
  cat
} > "tmp/${dst}" \
 && chmod a-wx "tmp/${dst}" \
 && mv "tmp/${dst}" "new/${dst}"

cat <<EndOfMessage
Status: 302 Found
Location: danke.html

Danke!
EndOfMessage
