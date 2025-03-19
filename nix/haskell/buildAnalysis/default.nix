# Run a python server in the pre-build that helps dump files sent by <https://github.com/juspay/spider> in `juspayMetadata/<package-name>` outpath.
{ pkgs, lib, name, mkCabalSettingOptions, ... }:
let
  # `preBuildHook` phase fails with `Permission Denied` while executing the bash script if `readFile` is not used
  preBuildHook = builtins.readFile (pkgs.substituteAll {
    src = ./preBuildHook.sh;
    env = {
      server = "${./server.py}";
    };
  });
  postBuildHook = builtins.readFile (pkgs.substituteAll {
    src = ./postBuildHook.sh;
    env = {
      packageName = name;
      endpointsExtract = "${./endpoints_extract.py}";
      envExtract = "${./env_extract.py}";
      getconfigkey = "${./getConfigKey.py}";
      tmpzip = "${./tmpzip.py}";
      fdep_merge = "${./fdep_merge.py}";
    };
  });
in
{
  options = mkCabalSettingOptions {
    name = "buildAnalysis";
    type = lib.types.bool;
    description = "Enable build analysis powered by <https://github.com/juspay/spider>";
    impl = enable: drv:
      if enable then
        drv.overrideAttrs
          (oa: {
            outputs = (oa.outputs) ++ [ "juspayMetadata" ];
            buildInputs = (oa.buildInputs or [ ]) ++ (with pkgs; [
              (python311.withPackages (p: with p; [ websockets aiohttp boto3 ]))
            ]);

            preBuildHooks = [ preBuildHook ];

            postBuildHooks = [ postBuildHook ];

            preInstallHooks = [ "mkdir -p $juspayMetadata/${name}" ];
          })
      else drv;
  };
}
