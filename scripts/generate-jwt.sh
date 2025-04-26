#!/usr/bin/env bash
set -euo pipefail

# sanity checks
[ -z "${PRIVATE_APP_KEY_FILEPATH:-}" ]      && { echo "Error: PRIVATE_APP_KEY_FILEPATH not set";      exit 1; }
[ -z "${GITHUB_APP_ID:-}" ]&& { echo "Error: GITHUB_APP_ID not set"; exit 1; }
[ -z "${JWT_TTL:-}" ]      && { echo "Error: JWT_TTL not set";      exit 1; }
[ -z "${ROOT_CA:-}" ] && echo "Warning: ROOT_CA not set"

# Optional: import custom root CA from environment variable
if [ -n "$ROOT_CA" ]; then
	echo "Installing custom root CA…"
	cp /etc/ssl/certs/ca-certificates.crt /tmp/custom-root-ca.crt
  	echo "$ROOT_CA" >>/tmp/custom-root-ca.crt
fi


base64url() { openssl enc -base64 -A | tr '+/' '-_' | tr -d '='; }
sign()     { openssl dgst -binary -sha256 -sign $PRIVATE_APP_KEY_FILEPATH; }

header=$(printf '{"alg":"RS256","typ":"JWT"}' | base64url)
now=$(date +%s); iat=$((now-60)); exp=$((now+JWT_TTL))
payload=$(printf '{"iss":"%s","iat":%s,"exp":%s}' "$GITHUB_APP_ID" "$iat" "$exp" | base64url)
signature=$(printf '%s.%s' "$header" "$payload" | sign | base64url)

# write it out
echo "JWT expiring at epoch $exp (in $JWT_TTL seconds)"
echo "$header.$payload.$signature" > /jwt/jwt.token
