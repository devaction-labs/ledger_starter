# syntax=docker/dockerfile:1
# CI builds with BuildKit and pushes to GHCR (ghcr.io/devaction-labs/ledger_starter);
# Openship deploys the CI-built image and does not build this file.
ARG ELIXIR_VERSION=1.20.5
ARG OTP_VERSION=29.1.2
ARG ALPINE_VERSION=3.24.3

FROM hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-alpine-${ALPINE_VERSION}@sha256:d4a56ccb80b8aeedcb7d9d4a56b4b5b229ec684aaea537dfac39cd146fb3aea5 AS builder

RUN apk add --no-cache build-base git

WORKDIR /app

ENV MIX_ENV=prod \
    LANG=C.UTF-8

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock ./
COPY config/config.exs config/prod.exs config/runtime.exs config/

# Hex has timed out mid-fetch from CI hosts: retry instead of failing the build.
ENV HEX_HTTP_TIMEOUT=120
RUN set -eu; \
    for i in 1 2 3 4 5; do \
      mix deps.get --only prod && break; \
      status=$?; \
      if [ "$i" = 5 ]; then exit "$status"; fi; \
      echo "mix deps.get failed (attempt $i/5); retrying in 10s..." >&2; \
      sleep 10; \
    done; \
    mix deps.compile

COPY priv priv
COPY lib lib
COPY assets assets
COPY rel rel

RUN mix compile && mix assets.deploy && mix release

FROM alpine:${ALPINE_VERSION}@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a AS runner

# `apk upgrade` before `add` so the image carries the current security patches;
# APK_REFRESH (github.run_id in CI) busts the layer cache on every build.
ARG APK_REFRESH=0
RUN echo "apk layer built for ${APK_REFRESH}" \
    && apk upgrade --no-cache \
    && apk add --no-cache bash openssl libgcc libstdc++ ncurses-libs tzdata curl \
    && addgroup -S appgroup \
    && adduser -S appuser -G appgroup

WORKDIR /app

ENV HOME=/app \
    MIX_ENV=prod \
    PHX_SERVER=true \
    LANG=C.UTF-8 \
    SKIP_MIGRATIONS=0

COPY --from=builder --chown=appuser:appgroup /app/_build/prod/rel/ledger_starter ./
COPY --chown=appuser:appgroup rel/entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh

USER appuser:appgroup

EXPOSE 4000

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD curl -fsS http://127.0.0.1:${PORT:-4000}/health/live || exit 1

CMD ["./entrypoint.sh"]
