{
  perSystem = { pkgs, lib, config, ... }: {
    packages.joinJuspayMetadata = pkgs.symlinkJoin {
      name = "joinJuspayMetadata";
      paths = lib.pipe config.haskellProjects.default.packages [
        (lib.mapAttrs (n: _: config.haskellProjects.default.outputs.finalPackages."${n}"))
        (lib.filterAttrs (_: v: v?juspayMetadata))
        (lib.mapAttrs (_: v: v.juspayMetadata))
        lib.attrValues
      ];
      meta.description = "Join the `juspayMetadata` output of packages defined in `haskellProjects.default.packages` (An option of `haskell-flake`)";
    };
  };
}

