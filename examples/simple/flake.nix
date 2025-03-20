{
  inputs = {
    common.url = "github:juspay/nix-common";
  };
  outputs = inputs:
    inputs.common.lib.mkFlake { inherit inputs; } {
      imports = [
        ./nix/haskell-project.nix
      ];

      perSystem = { self', config, pkgs, pkgs-latest, lib, ... }: {
        # haskell-flake doesn't set the default package, but you can do it here.
        packages.default = self'.packages.simple;

        # This module configures `packages.<linux-system>.dockerImage`
        euler-docker-image = {
          enable = true;
          package = self'.packages.default;
        };

        devShells.default = pkgs.mkShell {
          name = "example-simple";
          inputsFrom = [
            config.haskellProjects.default.outputs.devShell
            config.devShells.common
          ];
        };
      };
    };
}
