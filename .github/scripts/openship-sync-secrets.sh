#!/usr/bin/env bash
# Push the app's secrets and variables from the GitHub repository to the Openship project's
# production environment (PATCH /api/projects/:id/env), then read the keys back.
#
# The values arrive as environment variables of the same name (the workflow maps
# them from `secrets.*`). They go to Openship through stdin, never through argv
# or the log, and only key NAMES are ever printed.
#
# All-or-nothing: if any secret is empty in GitHub the script stops before
# sending anything, so a missing secret can never blank a key in production.
# The OPTIONAL_* names are sent only when they are non-empty in GitHub, so an
# unset variable never overwrites an Openship value with an empty string.
set -euo pipefail
set +x

SECRET_NAMES=(
  SECRET_KEY_BASE
  GOOGLE_CLIENT_SECRET
  RESEND_API_KEY
  DEMO_PASSWORD
)

# Non-secret envs on Openship, all optional (skipped when empty).
# GOOGLE_CLIENT_ID is a repo secret in GitHub but a plain env on Openship.
OPTIONAL_VAR_NAMES=(
  GOOGLE_CLIENT_ID
  PHX_HOST
  BASE_HOST
  MAIL_FROM
  POOL_SIZE
)

# DATABASE_URL is intentionally absent: Openship injects it through the DB connection.

if [ -z "${OPENSHIP_API_URL:-}" ] || [ -z "${OPENSHIP_API_TOKEN:-}" ] || [ -z "${OPENSHIP_PROJECT_ID:-}" ]; then
  echo "::error::Missing OPENSHIP_API_URL / OPENSHIP_API_TOKEN / OPENSHIP_PROJECT_ID"
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "::error::jq is required on the runner"
  exit 1
fi

API="${OPENSHIP_API_URL%/}"
AUTH=( -H "Authorization: Bearer ${OPENSHIP_API_TOKEN}" )

missing=()
for name in "${SECRET_NAMES[@]}"; do
  [ -n "${!name:-}" ] || missing+=("$name")
done

if [ "${#missing[@]}" -gt 0 ]; then
  echo "::error::Secrets empty or not set in GitHub: ${missing[*]}"
  exit 1
fi

upserts='[]'
optional_vars=()
for name in "${OPTIONAL_VAR_NAMES[@]}"; do
  if [ -n "${!name:-}" ]; then optional_vars+=("$name"); fi
done
for name in "${SECRET_NAMES[@]}"; do
  upserts=$(jq -c --arg k "$name" '. + [{key: $k, value: env[$k], isSecret: true}]' <<<"$upserts")
done
for name in ${optional_vars[@]+"${optional_vars[@]}"}; do
  upserts=$(jq -c --arg k "$name" '. + [{key: $k, value: env[$k], isSecret: false}]' <<<"$upserts")
done

code=$(jq -c --argjson ups "$upserts" -n \
  '{environment: "production", upserts: $ups, deletes: []}' |
  curl -sS -o /tmp/openship-env-patch -w "%{http_code}" --max-time 60 \
    -X PATCH "${API}/api/projects/${OPENSHIP_PROJECT_ID}/env" \
    "${AUTH[@]}" \
    -H "Content-Type: application/json" \
    --data @- || true)

echo "env PATCH HTTP_CODE=$code keys=$((${#SECRET_NAMES[@]} + ${#optional_vars[@]}))"

case "$code" in
  200|201|204) ;;
  *)
    echo "::error::Openship refused the env update (HTTP $code)"
    exit 1
    ;;
esac

code=$(curl -sS -o /tmp/openship-env-read -w "%{http_code}" --max-time 30 \
  "${API}/api/projects/${OPENSHIP_PROJECT_ID}/env?environment=production" \
  "${AUTH[@]}" || true)

if [ "$code" != "200" ]; then
  echo "::error::Could not read the env back (HTTP $code)"
  exit 1
fi

stale=()
for name in "${SECRET_NAMES[@]}"; do
  secret=$(jq -r --arg k "$name" '[.data[] | select(.key == $k)] | first | .isSecret // false' /tmp/openship-env-read)
  [ "$secret" = "true" ] || stale+=("$name")
done
for name in ${optional_vars[@]+"${optional_vars[@]}"}; do
  present=$(jq -r --arg k "$name" '[.data[] | select(.key == $k)] | length > 0' /tmp/openship-env-read)
  [ "$present" = "true" ] || stale+=("$name")
done

rm -f /tmp/openship-env-patch /tmp/openship-env-read

if [ "${#stale[@]}" -gt 0 ]; then
  echo "::error::Not stored in Openship after the update: ${stale[*]}"
  exit 1
fi

echo "Openship: ${#SECRET_NAMES[@]} secrets and ${#optional_vars[@]} variables stored: ${SECRET_NAMES[*]} ${optional_vars[*]-}"
