#!/bin/sh
# dump HTTP post requests. Nice for off-site, static website feedback.
#
# Use e.g. https://mro.name/form2xml to process them.

# where do you want to dump to?
cd "$(dirname "${0}")/../../../dumps" || exit 1

# https://stackoverflow.com/a/52363117
[ "${CONTENT_LENGTH}" -gt 0 ] || exit 2

dst="$(date +%FT%H%M%S).post"
{
  printf "%s: %s\r\n" "Content-Type" "${CONTENT_TYPE}"
  printf "%s: %s\r\n" "Content-Length" "${CONTENT_LENGTH}"
  printf "%s: \"%s\"\r\n" "User-Agent" "${HTTP_USER_AGENT}"
  printf "%s: %s\r\n" "Remote-Address" "${REMOTE_ADDR}"
  printf "\r\n"
  cat
} > "${dst}~" \
 && chmod a-wx "${dst}~" \
 && mv "${dst}~" "${dst}"

cat <<EndOfMessage
Status: 302 Found
Location: danke.html

Danke!
EndOfMessage
