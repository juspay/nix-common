common:
{ self, inputs, ... }:

{
  imports = [
    common.inputs.flake-root.flakeModule
    common.inputs.haskell-flake.flakeModule
    common.inputs.process-compose-flake.flakeModule
    ./nix/devshell-common.nix
    ./nix/haskell
    ./nix/pkgs.nix
    ./nix/pkgs-latest.nix
    ./nix/ghc928.nix
  ];
  perSystem = { system, inputs', lib, config, pkgs, pkgs-latest, ... }: {

    # TODO: remove after introducing treefmt
    formatter = pkgs-latest.nixpkgs-fmt;

    process-compose.services = {
      imports = [
        common.inputs.self.processComposeModules.default
      ];
    };
  };
}
