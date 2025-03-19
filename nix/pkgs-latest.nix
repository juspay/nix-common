{ inputs, ... }:
let
  bg_cachix_push = self: super: {
    bg_cachix_push = self.writeShellApplication {
      name = "cachix-push-default-build-and-devshell-outputs";
      runtimeInputs = [ self.coreutils self.cachix ];
      # TODO: refactor this
      text = ''
        set -x
        nix-store -qR --include-outputs "$(nix eval .#default.drvPath | tr -d '\"')" | cachix push euler

        nix-store -qR --include-outputs "$(nix eval .#devShells."$(nix eval --impure --expr "builtins.currentSystem")".default.drvPath | tr -d '\"')" | cachix push euler
      '';
    };
  };
in
{
  perSystem = { pkgs-latest, config, system, ... }: {
    _module.args.pkgs-latest = import inputs.nixpkgs-latest {
      inherit system;
      overlays = [
        bg_cachix_push
      ];
    };
  };
}
