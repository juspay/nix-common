# For more reproducible dev shell env
# cf. https://github.com/srid/haskell-flake/issues/160
{ ... }: {
  devShell.mkShellArgs.shellHook =
    ''
      export HIE_BIOS_CACHE_DIR=''${FLAKE_ROOT}/.hie-bios-cache
      export CABAL_DIR=''${FLAKE_ROOT}/.cabal-dir
    '';
}
