# homebrew-rar

A personal [Homebrew](https://brew.sh) tap for the `rar` cask, which was
[deprecated and scheduled for disabling](https://formulae.brew.sh/cask/rar)
in the official `homebrew/cask` tap (`disable! date: "2026-09-01"`, because it
fails the macOS Gatekeeper check). This tap keeps it installable.

## Install

```sh
brew tap ustinka/rar
brew install --cask ustinka/rar/rar
```

(`brew tap ustinka/rar` resolves to `https://github.com/ustinka/homebrew-rar`
via Homebrew's standard `homebrew-` naming convention.)

Alternatively, install straight from the cask file without tapping:

```sh
brew install --cask https://raw.githubusercontent.com/ustinka/homebrew-rar/main/Casks/rar.rb
```

## Updating the cask

When RARLAB ships a new version, bump `version` and refresh the checksums in
`Casks/rar.rb`:

```sh
brew fetch --cask ustinka/rar/rar   # downloads both arch tarballs
shasum -a 256 <downloaded tarball>  # or use `brew audit`/`brew bump-cask-pr` workflow
```

The `livecheck` block lets `brew livecheck --cask ustinka/rar/rar` report the
latest upstream version.

## Notes

The upstream `disable!` and `depends_on :macos` stanzas were removed/relaxed so
the cask stays installable. RAR for macOS is proprietary freeware from
[RARLAB](https://www.rarlab.com/); this tap only repackages the install recipe.
