#!/usr/bin/env bash
# Builds the signed apt repository of Forge with aptly.
#
#   DEB_DIR         directory with the .deb files (all architectures, all versions to keep)
#   GPG_KEY_ID      fingerprint of the signing key (secret key in the gpg keyring)
#   GPG_PASSPHRASE  its passphrase (empty for a key without one)
#   OUT_DIR         where the static site goes (default: public)
#   DISTRIBUTION    suite name (default: stable); one suite serves Debian and Ubuntu
#
# The result is a plain directory: dists/, pool/, the public key and an index page.
set -euo pipefail

: "${DEB_DIR:?set DEB_DIR}"
: "${GPG_KEY_ID:?set GPG_KEY_ID}"
OUT_DIR="${OUT_DIR:-public}"
DISTRIBUTION="${DISTRIBUTION:-stable}"
GPG_PASSPHRASE="${GPG_PASSPHRASE:-}"

compgen -G "$DEB_DIR/*.deb" > /dev/null || { echo "no .deb files in $DEB_DIR" >&2; exit 1; }

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
cat > "$work/aptly.conf" <<JSON
{
  "rootDir": "$work/aptly",
  "architectures": ["amd64", "arm64"],
  "gpgProvider": "gpg"
}
JSON
aptly() { command aptly -config="$work/aptly.conf" "$@"; }

# gpg 2.x asks for the passphrase through the agent; let aptly pass it on the command line.
mkdir -p ~/.gnupg && chmod 700 ~/.gnupg
grep -qs '^pinentry-mode loopback' ~/.gnupg/gpg.conf || echo 'pinentry-mode loopback' >> ~/.gnupg/gpg.conf
grep -qs '^allow-loopback-pinentry' ~/.gnupg/gpg-agent.conf || echo 'allow-loopback-pinentry' >> ~/.gnupg/gpg-agent.conf
gpgconf --kill gpg-agent || true

aptly repo create -distribution="$DISTRIBUTION" -component=main -comment="Forge" forge
aptly repo add forge "$DEB_DIR"
aptly repo show -with-packages forge

pass_args=()
if [ -n "$GPG_PASSPHRASE" ]; then
  printf '%s' "$GPG_PASSPHRASE" > "$work/passphrase"
  pass_args=(-passphrase-file="$work/passphrase")
fi
aptly publish repo -batch -origin=Forge -label=Forge -gpg-key="$GPG_KEY_ID" "${pass_args[@]}" forge

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"
cp -a "$work/aptly/public/." "$OUT_DIR/"
gpg --armor --export "$GPG_KEY_ID" > "$OUT_DIR/forge-archive-keyring.asc"
gpg --export "$GPG_KEY_ID" > "$OUT_DIR/forge-archive-keyring.gpg"
touch "$OUT_DIR/.nojekyll"
cp "$(dirname "$0")/index.html" "$OUT_DIR/index.html"
echo "apt repository written to $OUT_DIR"
