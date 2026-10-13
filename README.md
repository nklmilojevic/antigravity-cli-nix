# antigravity-cli-nix

Always up-to-date Nix package for the [Antigravity CLI](https://antigravity.google) (`agy`) - Google's agentic coding assistant in your terminal.

**Automatically updated hourly** from the official release manifests.

## Why this package?

The official installer (`curl -fsSL https://antigravity.google/cli/install.sh | bash`) drops a binary into `~/.local/bin` that self-updates in the background. This flake instead gives you:

- **Declarative installs** via NixOS, Home Manager, or `nix profile`
- **Pinned, reproducible versions** through your flake lock
- **Hourly automated updates** - new releases land here within an hour
- **No self-mutation** - the built-in auto-updater is disabled (`AGY_CLI_DISABLE_AUTO_UPDATE=1`), so the binary in the Nix store is the one that runs
- **Linux and macOS** on both x86_64 and aarch64

## Quick Start

```bash
# Run without installing
nix run github:nklmilojevic/antigravity-cli-nix

# Install to your profile
nix profile install github:nklmilojevic/antigravity-cli-nix
```

The binary is installed as `agy`.

## Using with Nix Flakes

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    antigravity-cli-nix.url = "github:nklmilojevic/antigravity-cli-nix";
  };

  outputs = { self, nixpkgs, antigravity-cli-nix }:
    let
      system = "x86_64-linux"; # or your system
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          antigravity-cli-nix.packages.${system}.default
        ];
      };
    };
}
```

### NixOS / Home Manager

```nix
{ inputs, pkgs, ... }:
{
  # NixOS
  environment.systemPackages = [
    inputs.antigravity-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Home Manager
  home.packages = [
    inputs.antigravity-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
```

### Overlay

An overlay is exposed as `overlays.default`, adding `pkgs.antigravity-cli`. The Antigravity CLI is unfree, so when using the overlay you need to allow it in your nixpkgs config:

```nix
nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "antigravity-cli" ];
```

The `packages.*` outputs already allow it, so no extra config is needed there.

## Technical Details

- Fetches the prebuilt release tarball from Google's release bucket, verified against the SHA-512 published in the official manifest
- On Linux, the binary is patched with `autoPatchelfHook` to run against Nix's glibc
- On macOS, the upstream code signature is left untouched
- Wrapped to set `AGY_CLI_DISABLE_AUTO_UPDATE=1`; use `nix flake update` instead of `agy update`

## Updating

Updates are automated by a GitHub Actions workflow that runs hourly, opens a PR, builds it on Linux (x86_64, aarch64) and macOS, and auto-merges when green.

Manually:

```bash
./scripts/update.sh --check
./scripts/update.sh --update
nix build && ./result/bin/agy --version
```

## Repository Settings

See [Repository Settings Documentation](.github/REPOSITORY_SETTINGS.md) for the GitHub settings the update workflow needs.

## License

This Nix packaging is licensed under the MIT License - see [LICENSE](LICENSE).

The Antigravity CLI itself is proprietary software by Google.
