# nix-common

Nix configuration shared across euler repositories.

## Outputs

- A `lib.mkFlake` function uses `flake-parts.lib.mkFlake`, in addition to providing:
    - Shared `nixpkgs` input
    - Shared `nixpkgs-latest` input
    - Automatic setting of `systems` (using nix-systems)
    - Automatic importing of the common flakeModule.
    - Automatic services (`redis`, `mysql` and `redis-cluster`) setup using <https://github.com/juspay/services-flake>.
- The common `flakeModule` provides:
    - Common Haskell configuration
        - GHC 9.2.8 package set
        - Avoid global tool caches (`no-global-cache.nix`)


## Tips

- Use `nix flake lock --update-input <input>` to update a specific input (if on `Nix >= 2.20` use `nix flake update <input>`)

