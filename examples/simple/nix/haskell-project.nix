{
  perSystem = { config, self', pkgs, pkgs-latest, lib, ... }: {

    haskellProjects.default = let fs = pkgs-latest.lib.fileset; in {
      projectRoot = builtins.toString (fs.toSource {
        root = ../.;
        fileset = fs.unions [
          ../src
          ../simple.cabal
        ];
      });

      autoWire = [ "packages" "apps" ];

      packages = { };

      settings = { };
    };
  };
}
