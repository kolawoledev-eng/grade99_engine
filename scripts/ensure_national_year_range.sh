#!/usr/bin/env bash
# Bulk top-up generated_questions via POST /api/admin/ensure-buckets (Claude).
# Requires: ENGINE_URL, ADMIN_API_KEY, curl.
#
# Usage:
#   export ADMIN_API_KEY=... ENGINE_URL=https://your-engine
#   ./scripts/ensure_national_year_range.sh JAMB "Use of English" 2020 2025
#
# Optional env: TARGET_PER_DIFFICULTY (default 40), MAX_QUESTIONS_TO_GENERATE (default 400).
# Syllabus topics must exist for each exam/year/subject. Ingest past papers via
# POST /api/admin/past-questions/bulk (X-Admin-Key).

set -euo pipefail
EXAM="${1:-JAMB}"
SUBJECT="${2:-Use of English}"
Y0="${3:-2020}"
Y1="${4:-2025}"
TARGET="${TARGET_PER_DIFFICULTY:-40}"
MAXGEN="${MAX_QUESTIONS_TO_GENERATE:-400}"

: "${ENGINE_URL:?Set ENGINE_URL}"
: "${ADMIN_API_KEY:?Set ADMIN_API_KEY}"

for ((y = Y0; y <= Y1; y++)); do
  echo "=== $EXAM $SUBJECT year=$y ==="
  body=$(printf '%s' "{\"exam\":\"${EXAM//\"/\\\"}\",\"year\":${y},\"subject\":\"${SUBJECT//\"/\\\"}\",\"target_per_difficulty\":${TARGET},\"max_questions_to_generate\":${MAXGEN}}")
  curl -sS -X POST "${ENGINE_URL}/api/admin/ensure-buckets" \
    -H "Content-Type: application/json" \
    -H "X-Admin-Key: ${ADMIN_API_KEY}" \
    -d "$body" | head -c 2000 || true
  echo
  sleep 2
done
