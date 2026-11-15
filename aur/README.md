# AUR packages

| Package | Source | Updates |
| --- | --- | --- |
| `forge-ide-bin` | the amd64 `.deb` of a GitHub release of `stdimnet/forge` | automatic: the workflow **Publish AUR package** |
| `forge-ide-git` | the default branch, built with `pnpm tauri build --no-bundle` | automatic: the workflow **Publish AUR git package** when its PKGBUILD changes |

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

**forge-ide-git** builds the latest commit of Forge on the user's machine; `pkgver()` follows
the commits, so a new Forge commit needs no push. The workflow **Publish AUR git package**
(`.github/workflows/aur-git.yml`) pushes `PKGBUILD`, `.SRCINFO` and `forge.desktop` to
`ssh://aur@aur.archlinux.org/forge-ide-git.git` whenever `aur/forge-ide-git/` changes on `main`
(the first push creates the package). It fetches the source once so `.SRCINFO` shows a current
version, and uses the same `AUR_SSH_PRIVATE_KEY`. To test the package on an Arch system:

```sh
cd aur/forge-ide-git
makepkg -si
```

Keep AUR clones outside this repository; a clone inside it hides its files from this
repository's git.

`forge-ide-git` builds from `stdimnet/forge`, which pulls `php-lsp` from a git dependency
(`packs/phpforge/builtin-lsp/Cargo.toml`). Both repositories are public, so the build works
without credentials.
