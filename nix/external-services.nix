{ inputs }:
{ pkgs, ... }:
let
  envs = import ./external-services-envs.nix;
in
{
  imports = [
    inputs.services-flake.processComposeModules.default
  ];
  services = {


    redis."redis" = {
      enable = true;
      port = envs.DEV_REDIS_CONNECT_PORT;
    };

    redis-cluster."redis-cluster" = {
      enable = true;
      nodes = {
        "n1" = { port = envs.DEV_REDIS_CLUSTER_CONNECT_PORT; };
        "n2" = { port = envs.DEV_REDIS_CLUSTER_CONNECT_PORT + 1; };
        "n3" = { port = envs.DEV_REDIS_CLUSTER_CONNECT_PORT + 2; };
        "n4" = { port = envs.DEV_REDIS_CLUSTER_CONNECT_PORT + 3; };
        "n5" = { port = envs.DEV_REDIS_CLUSTER_CONNECT_PORT + 4; };
        "n6" = { port = envs.DEV_REDIS_CLUSTER_CONNECT_PORT + 5; };
      };
    };

  };

}

