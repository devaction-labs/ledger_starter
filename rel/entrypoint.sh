#!/bin/sh
# Production entrypoint: migrate, then run the release (exec, so the BEAM is PID 1).
set -e

if [ "${SKIP_MIGRATIONS:-0}" = "1" ] || [ "${SKIP_MIGRATIONS:-0}" = "true" ]; then
  echo "==> SKIP_MIGRATIONS set, skipping migrate"
else
  echo "==> Running migrations..."
  /app/bin/ledger_starter eval "LedgerStarter.Release.migrate()"
fi

echo "==> Starting server..."
exec /app/bin/ledger_starter start
