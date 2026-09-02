#!/usr/bin/env bash
set -euo pipefail

: "${RESULT_REPO:?}"
: "${RESULT_TOKEN:?}"

branch="${RESULT_BRANCH:-ci-results}"
slot="${RUNNER_SLOT:-0}"
kind="${RUNNER_KIND:-job}"
base="public-ci/${GITHUB_RUN_ID:-local}/attempt-${GITHUB_RUN_ATTEMPT:-1}/${kind}-${slot}"

put_file() {
  local src="$1"
  local name="$2"
  [ -f "$src" ] || return 0

  local body
  body="$(python3 - "$src" "$branch" <<'PY'
import base64, json, pathlib, sys
path = pathlib.Path(sys.argv[1])
branch = sys.argv[2]
print(json.dumps({
    "message": "ci: store private runner evidence",
    "content": base64.b64encode(path.read_bytes()).decode("ascii"),
    "branch": branch,
}, separators=(",", ":")))
PY
)"

  curl --fail --silent --show-error     -X PUT     -H "Authorization: Bearer $RESULT_TOKEN"     -H "Accept: application/vnd.github+json"     -H "X-GitHub-Api-Version: 2022-11-28"     "https://api.github.com/repos/${RESULT_REPO}/contents/${base}/${name}"     -d "$body" >/dev/null
}

put_file /tmp/private-result.json result.json
put_file /tmp/private-job.log job.log
