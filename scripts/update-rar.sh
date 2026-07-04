#!/usr/bin/env bash
#
# Check RARLAB for the latest "RAR for macOS" release and, if it is newer than
# the version pinned in Casks/rar.rb, rewrite the cask's version and both
# sha256 checksums in place.
#
# Exits 0 whether or not an update was made. When run inside GitHub Actions it
# writes `updated=true|false` (and `version=<new>`) to $GITHUB_OUTPUT so a later
# step can decide whether to commit.
#
# Run locally with:  ./scripts/update-rar.sh
set -euo pipefail

cask="Casks/rar.rb"
page="https://www.rarlab.com/download.htm"

sha256() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | cut -d' ' -f1
  else
    shasum -a 256 "$1" | cut -d' ' -f1
  fi
}

emit() { # key=value -> GITHUB_OUTPUT when available
  [[ -n "${GITHUB_OUTPUT:-}" ]] && echo "$1" >> "$GITHUB_OUTPUT"
  return 0
}

html=$(curl -fsSL "$page")
arm_file=$(grep -oE 'rarmacos-arm-[0-9]+\.tar\.gz' <<<"$html" | head -1)
x64_file=$(grep -oE 'rarmacos-x64-[0-9]+\.tar\.gz' <<<"$html" | head -1)
latest=$(grep -oiE 'RAR for macOS ARM [0-9]+(\.[0-9]+)+' <<<"$html" | head -1 | grep -oE '[0-9]+(\.[0-9]+)+')

if [[ -z "$arm_file" || -z "$x64_file" || -z "$latest" ]]; then
  echo "::error::could not parse RARLAB download page (layout may have changed)"
  exit 1
fi

# The version embedded in the arm filename must match the dotted version we
# scraped, otherwise our URL/version assumptions no longer hold.
nodots_from_file=$(sed -E 's/rarmacos-arm-([0-9]+)\.tar\.gz/\1/' <<<"$arm_file")
if [[ "$nodots_from_file" != "${latest//./}" ]]; then
  echo "::error::version mismatch: filename=$nodots_from_file dotted=$latest"
  exit 1
fi

current=$(grep -oE 'version "[^"]+"' "$cask" | head -1 | grep -oE '[0-9]+(\.[0-9]+)+')
echo "current=$current latest=$latest"

if [[ "$current" == "$latest" ]]; then
  echo "rar is up-to-date ($current)"
  emit "updated=false"
  exit 0
fi

echo "new version available: $current -> $latest"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fsSL "https://www.rarlab.com/rar/$arm_file" -o "$tmp/arm.tgz"
curl -fsSL "https://www.rarlab.com/rar/$x64_file" -o "$tmp/x64.tgz"
arm_sha=$(sha256 "$tmp/arm.tgz")
x64_sha=$(sha256 "$tmp/x64.tgz")
echo "arm sha256: $arm_sha"
echo "x64 sha256: $x64_sha"

sed -E \
  -e "s/(version )\"[^\"]+\"/\1\"$latest\"/" \
  -e "s/(arm:[[:space:]]*)\"[0-9a-f]{64}\"/\1\"$arm_sha\"/" \
  -e "s/(intel:[[:space:]]*)\"[0-9a-f]{64}\"/\1\"$x64_sha\"/" \
  "$cask" > "$cask.tmp" && mv "$cask.tmp" "$cask"

echo "updated $cask to $latest"
emit "updated=true"
emit "version=$latest"
