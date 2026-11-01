# forge-dist

Distribution of Forge outside its own repository.

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
