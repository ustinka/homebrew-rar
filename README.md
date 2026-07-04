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

## Automatic updates

A scheduled GitHub Actions workflow (`.github/workflows/update-cask.yml`) runs
`scripts/update-rar.sh` daily at 12:00 UTC. The script scrapes RARLAB's
[download page](https://www.rarlab.com/download.htm) for the latest "RAR for
macOS" release; if it is newer than the version pinned in `Casks/rar.rb`, it
downloads both the arm and x64 tarballs, computes their sha256 checksums,
rewrites the cask, and commits the bump (`rar <version>`) directly to `main`.

Trigger it manually any time from the repo's **Actions** tab
("Update rar cask" → "Run workflow"), or run it locally:

```sh
./scripts/update-rar.sh   # updates Casks/rar.rb in place if a newer version exists
```

> **Note:** GitHub disables `schedule` triggers after 60 days without repo
> activity. Each automatic bump resets that clock; during long quiet stretches,
> a manual "Run workflow" (or any commit) re-arms the daily schedule.

## Updating the cask manually

If you prefer to bump by hand, edit `version` and refresh both checksums in
`Casks/rar.rb`. The `livecheck` block also lets
`brew livecheck --cask ustinka/rar/rar` report the latest upstream version.

## Notes

The upstream `disable!` and `depends_on :macos` stanzas were removed/relaxed so
the cask stays installable. RAR for macOS is proprietary freeware from
[RARLAB](https://www.rarlab.com/); this tap only repackages the install recipe.
