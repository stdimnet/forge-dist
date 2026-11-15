# AUR packages

| Package | Source | Updates |
| --- | --- | --- |
| `forge-ide-bin` | the amd64 `.deb` of a GitHub release of `stdimnet/forge` | automatic: the workflow **Publish AUR package** |
| `forge-ide-git` | the default branch, built with `pnpm tauri build --no-bundle` | none; `pkgver()` follows the commits |

Both install `/usr/bin/forge`, the desktop entry and the icons, and conflict with each other and
with every other package that installs a `forge` command (`forge-bin`, Foundry's `foundry`,
`foundry-bin`, `foundry-git`). The `forge-ide-` prefix exists because `forge-bin` and
`forge-git` are already taken on the AUR.

## Publish

**forge-ide-bin** is published automatically. Forge's release workflow sends the event
`forge-release` to this repository once a release is published, and the workflow
**Publish AUR package** (`.github/workflows/aur.yml`):

1. downloads `Forge_<version>_amd64.deb` from the release and sets `_ver`, `pkgrel=1` and the
   checksum in `forge-ide-bin/PKGBUILD`,
2. checks the source with `makepkg --verifysource` and generates `.SRCINFO` (in an
   `archlinux:base-devel` container),
3. pushes `PKGBUILD` and `.SRCINFO` to `ssh://aur@aur.archlinux.org/forge-ide-bin.git`.

It needs the repository secret `AUR_SSH_PRIVATE_KEY`: the private half of an SSH key added to
the maintainer's AUR account (My Account | SSH Public Key). Use a separate key for CI. To
republish a release by hand, start the workflow in the Actions tab with its tag. The PKGBUILD
here is the template; the version in it is not updated by the workflow.

**forge-ide-git** follows the commits through `pkgver()` and only needs a push when the PKGBUILD
itself changes. On an Arch system:

```sh
cd aur/forge-ide-git
makepkg -si               # build and test it
makepkg --printsrcinfo > .SRCINFO
```

Then copy `PKGBUILD`, `.SRCINFO` and `forge.desktop` into a clone of
`ssh://aur@aur.archlinux.org/forge-ide-git.git`, commit and push. Keep AUR clones outside this
repository; a clone inside it hides its files from this repository's git.

`forge-ide-git` builds from `stdimnet/forge`, which pulls `php-lsp` from a git dependency
(`packs/phpforge/builtin-lsp/Cargo.toml`). Both repositories are public, so the build works
without credentials.
