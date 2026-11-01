# AUR packages

| Package | Source | Updates |
| --- | --- | --- |
| `forge-bin` | the `.deb` of a GitHub release of `Reeperk/Forge` (amd64, arm64) | bump `pkgver`, run `updpkgsums` |
| `forge-git` | the default branch, built with `pnpm tauri build --no-bundle` | none; `pkgver()` follows the commits |

Both install `/usr/bin/forge`, the desktop entry and the icons, and conflict with each other.

## Publish (on an Arch system)

```sh
cd aur/forge-bin          # or forge-git
updpkgsums                # forge-bin only, after the release exists
makepkg -si               # build and test it
makepkg --printsrcinfo > .SRCINFO
```

Then copy `PKGBUILD` and `.SRCINFO` (and `forge.desktop` for `forge-git`) into a clone of
`ssh://aur@aur.archlinux.org/<package>.git`, commit and push. This needs an AUR account with your
SSH key; the AUR is public, so the sources it names must be reachable without a login.

## Before the first publish

- The release `.deb` must exist at `https://github.com/Reeperk/Forge/releases/download/v<pkgver>/Forge_<pkgver>_<arch>.deb`.
  Adjust the tag pattern in `forge-bin/PKGBUILD` if releases are tagged differently.
- `forge-git` builds from `Reeperk/Forge`, which pulls `php-lsp` from a git dependency
  (`packs/phpforge/builtin-lsp/Cargo.toml`). Both repositories must be readable without credentials,
  or the build fails for everyone but you.
- Neither PKGBUILD was run on an Arch system yet; `.SRCINFO` is generated there, not committed here.
