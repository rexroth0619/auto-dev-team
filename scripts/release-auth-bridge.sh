#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  release-auth-bridge.sh status [--state-file PATH] [--marker-file PATH]
  release-auth-bridge.sh browser-handoff --login-url URL [--state-file PATH] [--marker-file PATH] [--timeout SECONDS]
  release-auth-bridge.sh local-secret-store --service NAME
EOF
}

MODE="${1:-}"
shift || true

STATE_FILE=""
MARKER_FILE=""
LOGIN_URL=""
SERVICE_NAME=""
TIMEOUT_SECONDS="60"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --state-file)
      STATE_FILE="$2"
      shift 2
      ;;
    --marker-file)
      MARKER_FILE="$2"
      shift 2
      ;;
    --login-url)
      LOGIN_URL="$2"
      shift 2
      ;;
    --service)
      SERVICE_NAME="$2"
      shift 2
      ;;
    --timeout)
      TIMEOUT_SECONDS="$2"
      shift 2
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

auth_ready() {
  if [[ "${RELEASE_AUTH_READY:-}" == "1" ]]; then
    return 0
  fi
  if [[ -n "$STATE_FILE" && -f "$STATE_FILE" ]]; then
    return 0
  fi
  if [[ -n "$MARKER_FILE" && -f "$MARKER_FILE" ]]; then
    return 0
  fi
  return 1
}

case "$MODE" in
  status)
    if auth_ready; then
      printf 'auth-ready\n'
      exit 0
    fi
    printf 'auth-not-ready\n' >&2
    exit 2
    ;;
  browser-handoff)
    if [[ -z "$LOGIN_URL" ]]; then
      printf 'browser-handoff requires --login-url\n' >&2
      exit 1
    fi
    if auth_ready; then
      printf 'auth-ready\n'
      exit 0
    fi
    if command -v open >/dev/null 2>&1; then
      open "$LOGIN_URL" >/dev/null 2>&1 || true
    fi
    end_ts=$(( $(date +%s) + TIMEOUT_SECONDS ))
    while [[ $(date +%s) -lt "$end_ts" ]]; do
      if auth_ready; then
        printf 'auth-ready\n'
        exit 0
      fi
      sleep 1
    done
    printf 'browser handoff timed out waiting for auth marker\n' >&2
    exit 2
    ;;
  local-secret-store)
    if [[ "${RELEASE_SECRET_READY:-}" == "1" ]]; then
      printf 'secret-ready\n'
      exit 0
    fi
    if [[ -z "$SERVICE_NAME" ]]; then
      printf 'local-secret-store requires --service\n' >&2
      exit 1
    fi
    if command -v security >/dev/null 2>&1; then
      if security find-generic-password -s "$SERVICE_NAME" -w >/dev/null 2>&1; then
        printf 'secret-ready\n'
        exit 0
      fi
    fi
    printf 'secret-not-ready\n' >&2
    exit 2
    ;;
  *)
    usage
    exit 1
    ;;
esac
