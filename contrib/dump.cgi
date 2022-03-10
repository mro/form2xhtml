#!/bin/sh
# dump HTTP post requests. Nice for off-site, static website feedback.
#
# Use e.g. https://mro.name/form2xhtml to process them.

# where to dump to, adjust accordingly
readonly formname="myform"
# ensure existing maildir structure
cd "/var/spool/form2xhtml/dumps/${formname}/new/" \
  && cd "../tmp/" \
  || exit 1

# https://stackoverflow.com/a/52363117
[ $((CONTENT_LENGTH)) -gt 0 ] || exit 2

# max upload size, adjust accordingly
if [ $((CONTENT_LENGTH)) -gt $((10 * 1024 * 1024)) ] ; then
  cat <<EndOfMessage
Status: 413 Payload Too Large
Content-Type: text/plain; charset=UTF-8

Size too large
EndOfMessage
  exit 0
fi

# max backlog count, adjust accordingly
if [ $(($(ls ../new/????-??-??T??????.post | wc -l))) -ge 100 ] ; then
  cat <<EndOfMessage
Status: 429 Too Many Requests
Content-Type: text/plain; charset=UTF-8

Overflowing, traffic jam straight up ahead!
EndOfMessage
  exit 0
fi

# could be a nasty uuid in case
readonly dst="$(date +%FT%H%M%S).post"
{
  printf "%s: %s\r\n" "Content-Type" "${CONTENT_TYPE}"
  printf "%s: %s\r\n" "Content-Length" "${CONTENT_LENGTH}"
  # printf "%s: \"%s\"\r\n" "User-Agent" "${HTTP_USER_AGENT}"
  printf "%s: %s\r\n" "Remote-Address" "${REMOTE_ADDR}"
  printf "\r\n"
  cat
} > "./${dst}" \
 && chmod a-wx "./${dst}" \
 && mv -n "./${dst}" "../new/" \
 || exit 1
 # && make --silent -C .. \

cat <<EndOfMessage
Status: 302 Found
Content-Type: text/plain; charset=UTF-8
Location: 200.html

Danke!
EndOfMessage

