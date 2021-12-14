#!/bin/sh
# dump HTTP post requests. Nice for off-site, static website feedback.
#
# Use e.g. https://mro.name/form2xhtml to process them.

# where do you want to dump to?
# ensure existing maildir structure
cd "/var/spool/form2xhtml/dumps/" \
  && cd "tmp/" \
  && cd "../new/" \
  && cd ".." \
  || exit 1

# https://stackoverflow.com/a/52363117
[ $((CONTENT_LENGTH)) -gt 0 ] || exit 2

# upload size fuse
if [ $((CONTENT_LENGTH)) -gt $((10 * 1024 * 1024)) ] ; then
  cat <<EndOfMessage
Status: 400 Bad Request

Size too large
EndOfMessage
  exit 0
fi

# backlog count fuse
if [ $(($(ls ./new/????-??-??T??????.post | wc -l))) -gt 100 ] ; then
  cat <<EndOfMessage
Status: 503 Service Unavailable

Overflowing, traffic jam straight up ahead!
EndOfMessage
  exit 0
fi

readonly dst="$(date +%FT%H%M%S).post"
{
  printf "%s: %s\r\n" "Content-Type" "${CONTENT_TYPE}"
  printf "%s: %s\r\n" "Content-Length" "${CONTENT_LENGTH}"
  # printf "%s: \"%s\"\r\n" "User-Agent" "${HTTP_USER_AGENT}"
  printf "%s: %s\r\n" "Remote-Address" "${REMOTE_ADDR}"
  printf "\r\n"
  cat
} > "tmp/${dst}" \
 && chmod a-wx "tmp/${dst}" \
 && mv "tmp/${dst}" "new/"

cat <<EndOfMessage
Status: 302 Found
Location: 200.html

Danke!
EndOfMessage

