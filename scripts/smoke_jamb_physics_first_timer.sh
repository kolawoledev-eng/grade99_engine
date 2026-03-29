#!/usr/bin/env bash
# Smoke test: JAMB → Physics path (first-timer download-pack flow).
# Usage: from repo root,  ./engine/scripts/smoke_jamb_physics_first_timer.sh
# Or:    cd engine && ./scripts/smoke_jamb_physics_first_timer.sh
#
# Requires: curl, engine/.env with keys (for local engine + optional admin ensure).
# Set API_BASE=https://your-host  if not testing localhost:8000

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

BASE="${API_BASE:-http://127.0.0.1:8000}"
ADMIN="${ADMIN_API_KEY:-}"

echo "== Base URL: $BASE"
echo "== GET /health"
curl -sS "$BASE/health" | head -c 200 || true
echo ""
echo ""

echo "== JAMB subjects (expect Physics, no duplicate English if API merged)"
curl -sS "$BASE/api/exams/JAMB/subjects" | python3 -c "import sys,json; d=json.load(sys.stdin); print('count', len(d)); print([x.get('name') for x in d[:8]], '...')" 2>/dev/null || curl -sS "$BASE/api/exams/JAMB/subjects" | head -c 400
echo ""
echo ""

echo "== JAMB Physics topics 2025 (needs migration 009 on Supabase)"
curl -sS "$BASE/api/exams/JAMB/2025/Physics/topics" | python3 -c "import sys,json; d=json.load(sys.stdin); print('topic rows', len(d)); print([t.get('topic_name') for t in d[:5]], '...')" 2>/dev/null || echo "(topics request failed — run sql/009 on DB?)"
echo ""
echo ""

echo "== Download pack JAMB Physics (small limit; same as app offline fetch shape)"
curl -sS "$BASE/api/practice/download-pack?exam=JAMB&subject=Physics&years=2024,2025,2026&limit_per_year_difficulty=5" | python3 -c "import sys,json; m=json.load(sys.stdin); qs=m.get('questions')or[]; print('status', m.get('status'), 'count', m.get('count'), 'questions', len(qs)); print('sample keys', list(qs[0].keys())[:12] if qs else [])" 2>/dev/null || echo "(download-pack failed — is engine running?)"
echo ""
echo ""

if [[ -n "$ADMIN" && "${RUN_ENSURE_BUCKETS:-}" == "1" ]]; then
  echo "== POST ensure-buckets (RUN_ENSURE_BUCKETS=1, costs Claude tokens)"
  curl -sS -X POST "$BASE/api/practice/admin/ensure-buckets" \
    -H "Content-Type: application/json" \
    -H "X-Admin-Key: $ADMIN" \
    -d '{"exam":"JAMB","year":2025,"subject":"Physics","target_per_difficulty":5,"max_questions_to_generate":15,"topics":["Kinematics"]}' \
    | python3 -m json.tool 2>/dev/null | head -n 40 || true
  echo ""
else
  echo "== Skip ensure-buckets (set RUN_ENSURE_BUCKETS=1 to run; uses X-Admin-Key from .env)"
fi

echo ""
echo "Done. Manual app check: JAMB → download Physics → Continue → config → practise (Past / AI labels on questions)."
