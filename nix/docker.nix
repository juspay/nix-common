{ self, inputs, lib, flake-parts-lib, ... }:
let
  inherit (flake-parts-lib)
    mkPerSystemOption;
  inherit (lib)
    mkOption
    mkEnableOption
    types;
in
{
  options.perSystem = mkPerSystemOption ({ self', config, pkgs, pkgs-latest, system, ... }: {
    options = {
      euler-docker-image = mkOption {
        description = "Build docker image for euler projects.";
        type = types.submodule {
          options = {
            enable = mkEnableOption "euler-docker-image";
            package = mkOption {
              description = "Euler package";
              type = types.package;
            };
            extraPackages = mkOption {
              description = "Extra packages to include in the docker image under `copyToRoot`";
              type = types.listOf types.package;
              default = [ ];
            };
            extraEnvs = mkOption {
              description = "Extra Envs to add to the docker image";
              type = types.listOf types.str;
              default = [ ];
            };
            extraPaths = mkOption {
              description = "Extra paths to add to the root in the docker image";
              type = types.listOf types.path;
              default = [ ];
            };
          };
        };
        default = { };
      };
    };
    config =
      let
        cfg = config.euler-docker-image;
      in
      {
        packages = lib.optionalAttrs (cfg.enable && pkgs.stdenv.isLinux) {
          dockerImage =
            let
              imageName = cfg.package.pname;
              # rev is null if git tree is dirty
              # why not use `self.shortRev`?
              # shortRev only provides the first 7 charachters of the rev
              imageTag = lib.substring 0 8 (self.rev or "latest");
              # TODO: Use a smaller base image
              # Reasoning behind using this larger image was due to
              # alpine image (10x smaller) not being up-to-date with
              # fixes for vluneraibilities.
              debianFromDockerHub = pkgs.dockerTools.pullImage
                {
                  imageName = "debian";
                  imageDigest = "sha256:a447223100dffca974b8a56e12e504a1df49e9e10076810c5a25711135905881";
                  sha256 = "04a2d3kdqmh1hn7vkvbgnqgv8f45jnbw4zjad8px35043z1bn7lz";
                  finalImageName = "debian";
                  finalImageTag = "unstable-slim";
                };

              package-with-lp = pkgs.writeShellScriptBin "${cfg.package.pname}-with-lp"
                ''
                  _term() { 
                    child=`ps -ef | grep "bin/${cfg.package.pname}$" | awk '{print $2}' | head -n 1`
                    echo "Caught SIGTERM signal! Child PID $child"
                    kill -SIGTERM "$child" 2>/dev/null
                    if [[ -z "$EULER_GRACE_PERIOD" ]] 
                    then
                      TIMEOUT=61
                    else
                      TIMEOUT=$(($EULER_GRACE_PERIOD/1000 + 1))
                    fi
                    sleep $TIMEOUT
                  }

                  trap _term SIGTERM

                  wait $!
                '';
              extraPath = pkgs.symlinkJoin {
                name = "euler-docker-extra-paths";
                paths = cfg.extraPaths;
              };

              extraPaths = lib.pipe (builtins.readDir extraPath) [
                (lib.filterAttrs (_: v: v == "directory"))
                lib.attrNames
                (map (path: "/" + path))
              ];

            in
            pkgs-latest.dockerTools.buildImage {
              fromImage = debianFromDockerHub;
              name = imageName;
              created = "now";
              tag = imageTag;
              copyToRoot = pkgs.buildEnv {
                paths = with pkgs-latest; [
                  bashInteractive
                  coreutils-full
                  curl
                  tcpdump
                  inetutils
                  unixtools.netstat
                  iana-etc
                  cacert
                  ps
                  gnugrep
                  bind
                  unixtools.top
                  bind
                  (runCommand "tmp-dir" { } ''mkdir -p $out/tmp; chmod ugo=rwx $out/tmp'')
                  package-with-lp
                  extraPath
                ] ++ cfg.extraPackages;
                name = cfg.package.pname;
                pathsToLink = [
                  "/bin"
                  "/etc"
                ] ++ extraPaths;
              };
              config = {
                Cmd = [ "${lib.getExe package-with-lp}" ];
                Env = [ ] ++ cfg.extraEnvs;
              };
            };
        };
      };
  });
}
