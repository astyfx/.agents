---
name: the-cli-packaging
description: "Package a Node/TypeScript CLI as a distributable binary (Bun compile, pkg, node-sea) — cross-platform targets, macOS/Windows signing and notarization, install paths (Homebrew, npm). Use when shipping a CLI or picking a bundler, or the user says 'cli 배포', 'single binary 빌드', 'macos codesign notarize'."
compatible-tools: [claude, codex]
category: cli
test-prompts:
  - "cli 배포 파이프라인"
  - "bun으로 single binary 빌드"
  - "macos codesign notarize"
  - "windows signing"
  - "homebrew tap 만들기"
  - "cross-platform 빌드"
  - "cli release automation"
  - "single binary로 npm에 올리기"
---

# The CLI Packaging

Shipping a CLI means more than `bun build`. Users hit Gatekeeper on macOS,
SmartScreen on Windows, install-path weirdness on Linux, and auto-update
expectations everywhere. Agents that call your CLI expect a pinned
version to exist at a predictable path. This skill is the checklist.

## Use This Skill When

- Preparing the first release of a CLI (Stave's `stave` binary or similar).
- Adding a new platform target.
- Debugging signing / notarization failures.
- Setting up release automation (GitHub Actions, Homebrew tap, npm).
- Deciding between Bun compile, pkg, node-sea, or a traditional tarball.

## Do Not Use This Skill When

- The CLI is internal-only and runs from `bun run` (no packaging needed).
- You're bundling a library for npm (different rules).

## Bundler Choice

| Bundler | Strength | Watch out |
|---|---|---|
| **Bun compile** | fastest, tiny command, produces standalone binary | Bun runtime quirks; bun-only APIs must be replaceable |
| **pkg** (vercel/pkg) | widely used, Node compat | unmaintained (archived); slower startup |
| **node-sea** (Single Executable App) | official Node path | newer, fewer tools around it |
| **Deno compile** | only if the CLI is Deno-native | not applicable to Node-first code |
| **tarball + Node** | no single binary, users install Node | simplest but highest friction |

Default for Stave and adjacent CLIs: **Bun compile**. The CLI is already
Bun-first and the startup time matters for agent tool invocation.

```sh
bun build --compile --target=bun-darwin-arm64 ./src/cli.ts --outfile dist/stave-darwin-arm64
bun build --compile --target=bun-darwin-x64    ./src/cli.ts --outfile dist/stave-darwin-x64
bun build --compile --target=bun-linux-x64     ./src/cli.ts --outfile dist/stave-linux-x64
bun build --compile --target=bun-linux-arm64   ./src/cli.ts --outfile dist/stave-linux-arm64
bun build --compile --target=bun-windows-x64   ./src/cli.ts --outfile dist/stave-windows-x64.exe
```

## Version and Commit Embedding

The CLI must know its own version at runtime. Inject at build time:

```ts
// src/version.ts (generated)
export const VERSION = "__VERSION__";
export const COMMIT  = "__COMMIT__";
export const BUILT_AT = "__BUILT_AT__";
```

Replace via `--define` / a build step:

```sh
bun build --compile \
  --define "__VERSION__='$(jq -r .version package.json)'" \
  --define "__COMMIT__='$(git rev-parse --short HEAD)'" \
  --define "__BUILT_AT__='$(date -u +%FT%TZ)'" \
  ...
```

`cli version` reads these. `cli doctor` prints all three.

## macOS: Codesign + Notarize

Unsigned binaries on macOS hit "cannot be opened, the developer cannot be
verified". Users will `xattr -d com.apple.quarantine` once, and never
again. Sign.

### Prereqs

- Apple Developer account
- Developer ID Application certificate in Keychain
- App-specific password for notarization (stored in Keychain via
  `xcrun notarytool store-credentials`)

### Sign

```sh
codesign --force --options runtime --timestamp \
  --sign "Developer ID Application: Your Name (TEAMID)" \
  dist/stave-darwin-arm64
```

Flags:
- `--options runtime` enables hardened runtime (required for notarization)
- `--timestamp` embeds Apple's timestamp so the signature doesn't expire
  with the cert

### Entitlements (if needed)

If the CLI uses PTY / child processes / network, you likely don't need
entitlements (entitlements are for app-sandbox / specific capabilities).
A hardened-runtime-signed binary is enough for most CLIs.

Exception: if you ship inside a `.pkg` that installs to `/usr/local/bin`
and runs Installer, sign with `--entitlements` covering
`com.apple.security.cs.allow-jit` if the runtime JITs.

### Notarize

Zip the binary (notarytool accepts zip or pkg/dmg):

```sh
ditto -c -k --keepParent dist/stave-darwin-arm64 dist/stave-darwin-arm64.zip
xcrun notarytool submit dist/stave-darwin-arm64.zip \
  --keychain-profile "NOTARY_PROFILE" --wait
```

On success, staple:

```sh
# For .pkg/.dmg you staple the installer; for a bare binary, notarization
# status travels with the signature and is verified online the first time
# the user runs it. No stapling needed for bare binaries distributed via
# Homebrew tap / direct download.
```

Verify:

```sh
spctl --assess --type execute -vv dist/stave-darwin-arm64
# expect: accepted, source=Notarized Developer ID
```

## Windows: Authenticode

Unsigned .exe triggers SmartScreen. Users click "run anyway" the first
few times; agents can't click.

- Get a Code Signing certificate (DigiCert, Sectigo, etc.). EV cert gets
  you instant SmartScreen reputation; standard OV cert needs traction.
- Sign with `signtool` (Windows SDK):

```
signtool sign /fd SHA256 /tr http://timestamp.digicert.com /td SHA256 \
  /f cert.pfx /p %CERT_PASSWORD% dist\stave-windows-x64.exe
```

Or on macOS/Linux CI: `osslsigncode`.

## Linux

No signing required. Provide:

- A tarball (`stave-linux-x64.tar.gz`) containing the binary and a README.
- An install script pattern: `curl -sSf https://.../install.sh | sh`
  (fetch, checksum verify, move to `~/.stave/bin`, append to PATH).
- A SHA256SUMS file signed with `gpg --detach-sign` if you want verifiable
  downloads.
- Optional: `.deb` and `.rpm` via `nfpm` if adoption justifies it.

## Install Channels

Pick based on audience:

| Channel | Pros | Cons |
|---|---|---|
| **Homebrew tap** (macOS + Linux) | `brew install org/tap/stave`, auto-update path via `brew upgrade` | need to maintain a formula repo |
| **npm (`stave`)** | `npm i -g stave`, familiar | requires Node installed; bin wrapper must locate/download platform binary |
| **Direct download + install.sh** | no dependency | users don't get updates automatically |
| **Winget / Scoop** | Windows native | separate manifest to maintain |
| **GitHub Releases** | always ship here | users rarely visit Releases |

Recommended: **Homebrew tap + install.sh + GitHub Releases** as the core.
Add npm wrapper if a lot of your users are Node devs. The npm wrapper's
postinstall downloads the correct platform binary from GitHub Releases.

### Homebrew formula skeleton

```ruby
class Stave < Formula
  desc "Agentic harness IDE command line"
  homepage "https://stave.dev"
  version "1.2.0"

  on_macos do
    on_arm do
      url "https://github.com/org/stave/releases/download/v1.2.0/stave-darwin-arm64.tar.gz"
      sha256 "..."
    end
    on_intel do
      url "..."
      sha256 "..."
    end
  end
  on_linux do
    on_arm do ... end
    on_intel do
      url "..."
      sha256 "..."
    end
  end

  def install
    bin.install "stave"
  end

  test do
    assert_match "stave", shell_output("#{bin}/stave version")
  end
end
```

## Release Pipeline

GitHub Actions shape:

1. **Matrix build** across `(os: macos-14, ubuntu-24.04, windows-2022) x (arch: arm64, x64)`.
2. **macOS job** imports cert from a GitHub secret, signs, notarizes,
   uploads artifact.
3. **Windows job** signs with cert pulled from secret, uploads.
4. **Release job** (runs once) downloads all artifacts, produces SHA256SUMS,
   creates GitHub Release, pushes Homebrew formula update via a bot PR.
5. **npm publish job** (optional) updates the wrapper package with new
   version; postinstall fetches binaries at install time.

Secrets to store:
- `APPLE_CERTIFICATE_P12`, `APPLE_CERTIFICATE_PASSWORD`
- `APPLE_NOTARY_PROFILE` (or `APPLE_ID` + `APPLE_ID_PASSWORD` + `APPLE_TEAM_ID`)
- `WINDOWS_CERTIFICATE_P12`, `WINDOWS_CERTIFICATE_PASSWORD`
- `HOMEBREW_TAP_DEPLOY_KEY`

## Auto-Update

Two patterns for CLIs:

- **Brew/package manager** does update for you. `cli update` prints a
  hint to run `brew upgrade`.
- **Self-update**: `cli update` hits a versions endpoint, downloads the
  matching binary, verifies SHA256, swaps in place using a temp
  filename + rename (atomic on POSIX; use `MoveFileEx` on Windows).

For agent tool usage: **pin the version**. Agents should invoke a
specific binary path (`~/.stave/bin/stave-1.2.0`) so updates don't
change behavior mid-task. `cli version --json` is the source of truth
for what's installed.

## Size

Bun-compiled binaries start ~50MB (runtime included). Trim by:

- `bun build --minify`
- strip symbols: `strip dist/stave-*` (macOS/Linux)
- avoid bundling dev-only deps (audit with `bun build --analyze`)
- lazy-load heavy subcommands that aren't on the hot path

Don't chase sub-10MB — agents and users care far more about correctness
than binary size.

## SBOM and Checksums

Every release artifact gets:

- `SHA256SUMS` file listing all artifacts
- optional `SHA256SUMS.sig` GPG signature
- SBOM (`cyclonedx-node` or `syft`) if the downstream cares

## Anti-Patterns

- Shipping unsigned macOS binaries and telling users to `xattr -d`.
- Hardcoding the install path in error messages — use `process.execPath`.
- One "universal" binary that embeds all arches — fat binaries waste
  bandwidth at install; ship per-arch.
- `curl | bash` installer without a SHA256 check.
- Releasing without running `cli doctor` on the fresh binary inside CI.

## Stave-Specific Notes

- The CLI binary should coexist with the Stave desktop app. Install path
  default: `~/.stave/bin/stave`. Desktop app adds that path to user's
  shell profile via a dedicated command (`stave install-path --shell bash`).
- `stave doctor` checks: CLI version, desktop app version, mutual
  compatibility, workspace DB writability, provider auth.
- A fresh macOS machine must be able to `brew install stave` and run
  `stave --help` with no prompts, no Gatekeeper popup, no Rosetta
  translation warning.

## Integration with Other Skills

- `the-cli-designer`: the surface being packaged.
- `the-agent-cli`: ensure agent tool definitions carry the pinned
  binary version.
- `the-subprocess-orchestrator`: when the CLI spawns helpers, package
  them alongside or fetch on first run.
- `the-build-fixer`: CI failures on build / sign / notarize steps.

## Done Definition

- All target platforms build reproducibly.
- macOS binary is signed + notarized; verified with `spctl`.
- Windows binary is signed; verified with `signtool verify`.
- Version + commit + build time are embedded and reported by
  `cli version --json`.
- At least one install channel (Homebrew tap recommended) works
  end-to-end: fresh machine → install → run → uninstall clean.
- Release pipeline is automated in CI; human only tags and reviews the
  release PR.
- SHA256SUMS accompanies every release.
