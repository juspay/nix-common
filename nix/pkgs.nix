{ inputs, flake-parts-lib, ... }: {
  options.perSystem = flake-parts-lib.mkPerSystemOption ({ pkgs-latest, config, system, ... }:
    let
      ghc-perf-tools-overlay-ghc9 = self: super: {
        haskell = super.haskell // {
          compiler = super.haskell.compiler // {
            ghc928-perf-events = (super.haskell.compiler.ghc928.overrideAttrs (drv: {
              patches = drv.patches ++ [ ./haskell/0001-Add-a-primop-to-get-the-thread-statistics.patch ./haskell/added-support-for-desugar-plugin.patch ];
            }));
          };
          packages = super.haskell.packages // {
            ghc928-perf-events = super.haskell.packages.ghc928.override {
              buildHaskellPackages = self.buildPackages.haskell.packages.ghc928-perf-events;
              ghc = self.buildPackages.haskell.compiler.ghc928-perf-events;
            };
          };
        };
      };
    in
    {
      imports = [
        "${inputs.nixpkgs}/nixos/modules/misc/nixpkgs.nix"
      ];
      nixpkgs = {
        hostPlatform = system;
        overlays = [
          ghc-perf-tools-overlay-ghc9
          (_: _: {
            inherit (pkgs-latest) process-compose;
            omnix = inputs.common.inputs.omnix.packages.${system}.default;
          })
        ];
      };
    });
}
