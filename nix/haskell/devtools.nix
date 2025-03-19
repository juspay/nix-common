{ ... }:

{
  devShell.tools = hp: {
    inherit (hp)
      ghcid
      haskell-language-server
      ;
  };
}
