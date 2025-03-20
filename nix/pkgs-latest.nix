{ inputs, ... }:
{
  perSystem = { pkgs-latest, config, system, ... }: {
    _module.args.pkgs-latest = import inputs.nixpkgs-latest {
      inherit system;
    };
  };
}
