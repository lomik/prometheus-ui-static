#!/bin/sh

set -e

cd "$(dirname "$0")"

# Prometheus builds its web UI with pnpm (see web/ui/.nvmrc for the Node.js version).
if ! command -v pnpm >/dev/null 2>&1; then
	echo "pnpm is required (e.g. npm install -g 'pnpm@<13')" >&2
	exit 1
fi

# BRANCH=$(grep 'github.com/prometheus/prometheus' go.mod | awk '{print $2}')
BRANCH=v0.316.0

rm -rf tmp
mkdir tmp
git clone --depth 1 --branch "$BRANCH" https://github.com/prometheus/prometheus.git tmp

cd tmp
make assets-compress

cd ..
rm -rf static
cp -a tmp/web/ui/static static
rm -rf static/vendor

cp embed.go.tmpl embed.go
find static -type f -print0 | xargs -0 -I % echo % | sort | xargs echo //go:embed >> embed.go
echo var EmbedFS embed.FS >> embed.go

cp tmp/LICENSE LICENSE
cp tmp/NOTICE NOTICE
