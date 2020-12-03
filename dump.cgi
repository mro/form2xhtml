#!/bin/sh
# dump HTTP post requests. Nice for off-site, static website feedback.
#
# Use e.g. https://code.mro.name/mro/form2xml to process them.

# where do you want to dump to?
cd "$(dirname "${0}")/../../../dumps" || exit 1

# https://stackoverflow.com/a/52363117
[ "$CONTENT_LENGTH" -gt 0 ] || exit 2

dst="$(date +%FT%H%M%S).post"
cat > "${dst}~" \
 && chmod a-wx "${dst}~" \
 && mv "${dst}~" "${dst}"

cat <<EndOfMessage
Status: 302 Found
Location: danke.html

Danke!
EndOfMessage
