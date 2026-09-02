#!/usr/bin/env bash
set -euo pipefail

: "${SOURCE_REPO:?}"
: "${SOURCE_REF:?}"
: "${SOURCE_TOKEN:?}"

dest="${1:-private-src}"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

umask 077
mkdir -p "$dest"

curl --fail --silent --show-error --location   --retry 3 --retry-all-errors   -H "Authorization: Bearer $SOURCE_TOKEN"   -H "Accept: application/vnd.github+json"   -H "X-GitHub-Api-Version: 2022-11-28"   "https://api.github.com/repos/${SOURCE_REPO}/tarball/${SOURCE_REF}"   -o "$tmp"

tar -xzf "$tmp" -C "$dest" --strip-components=1
test -f "$dest/ci/public-runner/dispatch-build.sh" ||   test -f "$dest/ci/public-runner/dispatch-android.sh"
