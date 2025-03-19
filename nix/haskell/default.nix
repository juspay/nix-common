{ ... }:
{
  perSystem = { pkgs-latest, lib, config, system, ... }: {
    haskellProjects.default = project: {
      imports = [
        ./no-global-cache.nix
        ./devtools.nix
        ./default-settings.nix
      ];

      defaults.settings.all = {
        imports = [
          ./hpc.nix
          ./buildAnalysis
        ];
      };

      settings = {
        # Disable tests for monad-par as it depends on outdated langauge-haskell-extract, comes up when we override GHC
        monad-par.check = false;
      };
      devShell.hoogle = lib.mkDefault false;
      basePackages = config.haskellProjects.ghc928.outputs.finalPackages;
    };
  };
}
