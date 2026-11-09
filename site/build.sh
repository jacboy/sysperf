#!/usr/bin/env bash
# Builds the getsysperf.com site into ./dist.
# Cloudflare Pages: build command "bash site/build.sh", build output directory "dist".
# The script served at /bench is the repository's own ./bench, so the site and the
# script always come from the same commit.
set -euo pipefail

cd "$(dirname "$0")/.."

out="dist"
# Where the site will be served; the commands on the page point there.
# Default: production. The test deployment sets SITE_URL=https://sysperf.jf-l.de.
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

rm -rf "$out"
mkdir -p "$out"
cp site/index.html site/style.css site/copy.js site/favicon.svg site/_headers "$out"/
cp bench "$out/bench"

sha=$(sha256sum bench | cut -d' ' -f1)
echo "$sha  bench" > "$out/bench.sha256"
sed -i "s/__VERSION__/${version}/g; s/__SHA256__/${sha}/g; s#https://getsysperf\.com#${site_url}#g" "$out/index.html"

if grep -q '__VERSION__\|__SHA256__' "$out/index.html"; then
    echo "build.sh: placeholders left in index.html" >&2
    exit 1
fi
echo "Built sysperf ${version} site for ${site_url} into ${out}/ (bench sha256 ${sha})"
