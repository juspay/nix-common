# Configuration for https://github.com/juspay/omnix
{
  flake = {
    om.health.default = {
      rosetta.required = true;
      caches.required = [ "https://euler.cachix.org" ];
      # TODO: mk required = true; post the end of euler-tools 
      direnv.required = false;
      system = {
        required = true;
        min_ram = "16G";
        # Office Mac's don't have enough space
        min_disk_space = "490.0 GB";
      };
    };
  };
}
