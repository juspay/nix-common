{ config, lib, ... }:
let
  inherit (lib)
    mkOption
    types;
in
{
  options.default-settings = mkOption {
    type = types.deferredModule;
    description = ''
      Default settings for all packages defined in the current project.
    '';
    default = { };
  };
  config = {
    defaults.settings.local = if config.defaults.enable then config.default-settings else { };
  };
}
