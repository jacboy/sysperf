#!/usr/bin/env bash
# Builds the getsysperf.com site into ./dist.
# Cloudflare Pages: build command "bash site/build.sh", build output directory "dist".
# The script served at /bench is the repository's own ./bench, so the site and the
# script always come from the same commit.
set -euo pipefail

cd "$(dirname "$0")/.."

out="dist"
# Where the site will be served; the commands on the page point there.
# Default: production (https://getsysperf.com); set SITE_URL for a preview build.
site_url="${SITE_URL:-https://getsysperf.com}"
if [[ ! "$site_url" =~ ^https://[a-z0-9.-]+$ ]]; then
    echo "build.sh: SITE_URL must look like https://example.com (got '${site_url}')" >&2
    exit 1
fi
version=$(sed -n 's/^SYSPERF_VERSION="\([^"]*\)"$/\1/p' bench)
if [ -z "$version" ]; then
    echo "build.sh: SYSPERF_VERSION not found in bench" >&2
    exit 1
fi
bash -n bench

# The page names the commit the site is built from and tells visitors to compare /bench
# with that commit on GitHub, so the served bench must be exactly the committed one.
commit="${GITHUB_SHA:-$(git rev-parse HEAD 2>/dev/null || true)}"
if [[ ! "$commit" =~ ^[0-9a-f]{40}$ ]]; then
    echo "build.sh: cannot determine the git commit (got '${commit}')" >&2
    exit 1
fi
if ! git diff --quiet "$commit" -- bench 2>/dev/null; then
    echo "build.sh: bench differs from commit ${commit}; commit it first" >&2
    exit 1
fi

rm -rf "$out"
mkdir -p "$out"
cp site/index.html site/style.css site/copy.js site/favicon.svg site/_headers "$out"/
cp bench "$out/bench"

sha=$(sha256sum bench | cut -d' ' -f1)
echo "$sha  bench" > "$out/bench.sha256"
sed -i "s/__VERSION__/${version}/g; s/__SHA256__/${sha}/g; s/__COMMIT_SHORT__/${commit:0:7}/g; s/__COMMIT__/${commit}/g; s#https://getsysperf\.com#${site_url}#g" "$out/index.html"

if grep -q '__VERSION__\|__SHA256__\|__COMMIT' "$out/index.html"; then
    echo "build.sh: placeholders left in index.html" >&2
    exit 1
fi
echo "Built sysperf ${version} (commit ${commit:0:7}) site for ${site_url} into ${out}/ (bench sha256 ${sha})"
