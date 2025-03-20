{ inputs, ... }:
{
  imports = [
    inputs.common.inputs.omnix-flake.flakeModules.default
  ];
  perSystem = { system, inputs', lib, config, pkgs, pkgs-latest, ... }: {
    devShells.common =
      pkgs.mkShell {
        name = "euler-nix-common-shell";
        inputsFrom = [
          config.flake-root.devShell
          config.om.health.outputs.devShell
        ];
        packages = with pkgs-latest; [
          just
          nixd
        ] ++ [
          # Sets `LOCALE_ARCHIVE` to the one from `nixpkgs` instead of defaulting to global. See https://nixos.wiki/wiki/Locales.
          pkgs.glibcLocales
        ] ++ [
          config.process-compose.services.services.redis."redis".package
        ];

        # If we don't redirect 3>&1 direnv will hang while loading the environment: https://github.com/direnv/direnv/issues/755#issuecomment-800129928
        shellHook =
          let
            exports = lib.pipe (import ./external-services-envs.nix) [
              (lib.mapAttrsToList (n: v: ''
                export ${n}=${builtins.toString v}
              ''))
              (lib.concatStrings)
            ];
          in
          ''
            ${if pkgs-latest.stdenv.isDarwin then "ulimit -s 65000" else ""}
            if [ -f "justfile" ]; then
              echo "🍎🍎 Run 'just <recipe>' to get started"
              just
            fi
            ${exports}
          '';
      };
  };
}
