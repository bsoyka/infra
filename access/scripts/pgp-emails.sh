#!/usr/bin/env bash
# Terraform `external` data source (see ../groups.tf).
#
# Input (JSON on stdin):  {"url": "...", "fingerprint": "<40 hex chars>"}
# Output (JSON):          {"emails": "a@x,b@y"}
#
# Fetches the published key, checks it's exactly the pinned primary key, and
# lists the email addresses of user IDs that are neither revoked nor expired.
# Any problem exits non-zero, which fails the plan; that's the point.
set -euo pipefail

input=$(cat)
url=$(jq -r '.url' <<<"$input")
want=$(jq -r '.fingerprint' <<<"$input" | tr -d ' ' | tr '[:lower:]' '[:upper:]')

# A throwaway keyring: --show-keys doesn't import anything, but this keeps gpg
# from touching (or reading trust from) the real one.
GNUPGHOME=$(mktemp -d)
export GNUPGHOME
trap 'rm -rf "$GNUPGHOME"' EXIT

key=$(curl -fsSL --proto '=https' --max-time 20 "$url") || {
  echo "pgp-emails: couldn't fetch $url" >&2
  exit 1
}

listing=$(gpg --batch --quiet --with-colons --show-keys <<<"$key") || {
  echo "pgp-emails: gpg couldn't parse the key at $url" >&2
  exit 1
}

# Exactly one primary key, and its fingerprint (the fpr line right after pub)
# must be the pinned one.
pubs=$(awk -F: '$1 == "pub"' <<<"$listing" | wc -l | tr -d ' ')
if [ "$pubs" != 1 ]; then
  echo "pgp-emails: expected 1 primary key at $url, found $pubs" >&2
  exit 1
fi
got=$(awk -F: '$1 == "pub" { p = 1; next } p && $1 == "fpr" { print $10; exit }' <<<"$listing")
if [ "$got" != "$want" ]; then
  echo "pgp-emails: fingerprint mismatch at $url (got $got, want $want)" >&2
  exit 1
fi

# The primary key itself must be usable (field 2: r = revoked, e = expired).
case $(awk -F: '$1 == "pub" { print $2 }' <<<"$listing") in
  r | e)
    echo "pgp-emails: the key at $url is revoked or expired" >&2
    exit 1
    ;;
esac

# uid lines: field 2 is validity, field 10 is "Name (comment) <email>". gpg
# percent/backslash-escapes some characters in field 10, but not the ones an
# email address uses.
emails=$(
  awk -F: '$1 == "uid" && $2 != "r" && $2 != "e" { print $10 }' <<<"$listing" |
    sed -n 's/.*<\([^<>]*@[^<>]*\)>.*/\1/p' |
    tr '[:upper:]' '[:lower:]' |
    sort -u |
    paste -sd, -
)

if [ -z "$emails" ]; then
  echo "pgp-emails: no usable email user IDs on the key at $url" >&2
  exit 1
fi

jq -n --arg emails "$emails" '{emails: $emails}'
