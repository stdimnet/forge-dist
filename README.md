# forge-dist

Distribution of Forge outside its own repository.

## AUR (Arch)

`aur/` holds the PKGBUILDs of `forge-ide-bin` (GitHub releases) and `forge-ide-git` (latest source); see
[aur/README.md](aur/README.md).

## apt repository (Debian and Ubuntu)

`deb/build-repo.sh` builds a signed apt repository with [aptly](https://www.aptly.info/) from the
`.deb` files of the Forge releases. The workflow `.github/workflows/apt.yml` runs it and
publishes the result on GitHub Pages. One suite, `stable`, serves Debian 12+ and Ubuntu 22.04+
(amd64 and arm64): the packages are the same, so no per-release suites are needed.

### Install (users)

```sh
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://<pages-address>/forge-archive-keyring.asc | sudo tee /etc/apt/keyrings/forge.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/forge.asc] https://<pages-address> stable main" | sudo tee /etc/apt/sources.list.d/forge.list
sudo apt update && sudo apt install forge
```

The page itself shows the commands with its own address.

### Set up (once)

1. Create a signing key without an expiry that is only for this repository:
   `gpg --quick-generate-key "Forge Archive <you@example.com>" rsa4096 sign never`
2. Add these repository secrets (Settings | Secrets and variables | Actions):
   - `GPG_PRIVATE_KEY`: `gpg --armor --export-secret-keys <fingerprint>`
   - `GPG_PASSPHRASE`: its passphrase (empty if none)
   - `SOURCE_TOKEN`: a token that can read the releases of `Reeperk/Forge` (not needed once it is public)
3. Settings | Pages | Source: **GitHub Actions**. GitHub Pages of a private repository needs a
   paid plan, and the published site is public either way.

### Publish

After a Forge release is published, run the workflow **Publish apt repository** (Actions tab).
It rebuilds the repository from the latest releases (default 5), so old versions drop out by
themselves.

The script was written without a test run against a real signing key; run the workflow once
and check `apt update` on a Debian and an Ubuntu machine before announcing the repository.

## Release signing key

`keys/forge-release.asc` is the public key that signs `SHA256SUMS` of every Forge release
(`SHA256SUMS.asc`):

```
Forge Releases <releases@forge.hesselmann.me>
EF5D E928 3333 940B A443  2214 A508 B1D9 C16A 79DA
```

Verify a download:

```sh
curl -fsSL https://raw.githubusercontent.com/Reeperk/forge-dist/main/keys/forge-release.asc | gpg --import
gpg --verify SHA256SUMS.asc SHA256SUMS
sha256sum --ignore-missing -c SHA256SUMS
```

Check that the fingerprint `gpg --verify` prints matches the one above.
