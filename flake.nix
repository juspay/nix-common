{
  inputs = {
    # `nixpkgs`, `haskell-flake` and `flake-parts` will be shared between all the euler repos.
    nixpkgs.url = "github:nixos/nixpkgs/75a52265bda7fd25e06e3a67dee3f0354e73243c";
    # This will be used for fetching latest utils like cachix
    # and other packages added to the docker image.
    # (Cachix from nixpkgs above expects a different config schema)
    nixpkgs-latest.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    haskell-flake.url = "github:srid/haskell-flake";
    flake-parts.url = "github:hercules-ci/flake-parts";

    flake-root.url = "github:srid/flake-root";

    services-flake.url = "github:juspay/services-flake";
    process-compose-flake.url = "github:Platonic-Systems/process-compose-flake";

    omnix.url = "github:juspay/omnix";
    omnix-flake.url = "github:juspay/omnix?dir=nix/om";

    streamly-serialize-instances = {
      url = "github:composewell/streamly-serialize-instances/4ec75970db80429760f3acf3fc5918068f636e37";
      flake = false;
    };
    hedis = {
      url = "github:juspay/hedis/c9c81e3582cb029d491176f0894688d95355bfd9";
      flake = false;
    };
    streamly-core = {
      url = "github:composewell/streamly/12d85026291d9305f93f573d284d0d35abf40968";
      flake = false;
    };
    prometheus-haskell = {
      url = "github:juspay/prometheus-haskell/f1d996bb317d0a50450ace2b4ae08b5afdf22955";
      flake = false;
    };
    amazonka = {
      url = "github:juspay/amazonka/0132570eeb574ff30bbc0a4ad3ebd41ff64b5183";
      flake = false;
    };
    inline-js-nau = {
      url = "github:juspay/inline-js-nau/240cf0b59196e6d2ee0f24628051ff9743214298";
      flake = false;
    };
    word24 = {
      url = "github:winterland1989/word24/445f791e35ddc8098f05879dbcd07c41b115cb39";
      flake = false;
    };
    tinylog = {
      url = "gitlab:arjunkathuria/tinylog/08d3b6066cd2f883e183b7cd01809d1711092d33";
      flake = false;
    };
    servant-mock = {
      url = "github:arjunkathuria/servant-mock/17e90cb831820a30b3215d4f164cf8268607891e";
      flake = false;
    };
    servant-errors = {
      url = "github:epicallan/servant-errors/7c564dff3574c35cae721b711bd90503b851438e";
      flake = false;
    };
    servant-client = {
      url = "github:haskell-servant/servant/1fba9dc6048cea6184964032b861b052cd54878c"; # FIX: for default addition of '?' for nonempty query strings
      flake = false;
    };

    cereal = {
      url = "github:juspay/cereal/d8973650f19acc31b75205cc72d919e2d2589992";
      flake = false;
    };
    jrec = {
      url = "github:juspay/jrec/3be4f9c86a59c40e5c83a7d4497f7b15cecafc94";
      flake = false;
    };
    mysql-haskell = {
      url = "github:juspay/mysql-haskell/0c290a5ec4296e7f74d488cbdeb9f384dfb1f04d";
      flake = false;
    };
    beam-mysql = {
      url = "github:juspay/beam-mysql/501e6e570a93b212d942879daae18893fe22248a";
      flake = false;
    };
    beam = {
      url = "github:juspay/beam/b5f14b640110bcfab6bc86f07f864516b2d7ffd8";
      flake = false;
    };
    aeson-nau = {
      url = "github:juspay/aeson-nau/ghc-9.2.8-aeson-show-fix";
      flake = false;
    };
    ghc-hasfield-plugin = {
      url = "github:eswar2001/ghc-hasfield-plugin/c932ebc0d7e824129bb70c8a078f3c68feed85c9";
      inputs.flake-parts.follows = "flake-parts";
      inputs.systems.follows = "spider/systems";
      inputs.haskell-flake.follows = "haskell-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    classyplate = {
      url = "github:eswar2001/classyplate/a360f56820df6ca5284091f318bcddcd3e065243";
      inputs.flake-parts.follows = "flake-parts";
      inputs.systems.follows = "spider/systems";
      inputs.haskell-flake.follows = "haskell-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    references = {
      url = "github:eswar2001/references/120ae7826a7af01a527817952ad0c3f5ef08efd0";
      inputs.flake-parts.follows = "flake-parts";
      inputs.haskell-flake.follows = "haskell-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    large-records = {
      url = "github:eswar2001/large-records?ref=ghc928-qualified-prelude";
      inputs.flake-parts.follows = "flake-parts";
      inputs.systems.follows = "spider/systems";
      inputs.haskell-flake.follows = "haskell-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.ghc-hasfield-plugin.follows = "ghc-hasfield-plugin";
      inputs.beam.follows = "beam";
    };
    # `fast-time` with parser fixes
    fast-time = {
      url = "github:juspay/fast-time/ca59e1d7a778641de9509ed90c71620b391f31e9";
      flake = false;
    };
    
    spider = {
      url = "github:juspay/spider/ghc-9.2.8";
      inputs.flake-parts.follows = "flake-parts";
      inputs.haskell-flake.follows = "haskell-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.classyplate.follows = "classyplate";
      inputs.references.follows = "references";
      inputs.large-records.follows = "large-records";
      inputs.streamly.follows = "streamly-core";
    };

  };
  outputs = inputs: {
    flakeModules = {
      default = import ./flake-module.nix { inherit inputs; };
      ghc928 = ./nix/ghc928.nix;
    };
    lib.mkFlake = args: mod:
      inputs.flake-parts.lib.mkFlake
        { inputs = args.inputs // { inherit (inputs) nixpkgs nixpkgs-latest; }; }
        {
          systems = [ "x86_64-linux" "aarch64-darwin" ];
          imports = [
            inputs.self.flakeModules.default
            ./nix/docker.nix
            ./nix/om.nix
            ./nix/haskell/buildAnalysis/juspayMetadata.nix
            mod
          ];
        };
    processComposeModules.default =
      import ./nix/external-services.nix { inherit inputs; };
    environments.externalServices = import ./nix/external-services-envs.nix;

    om.ci.default = {
      simple-example = {
        overrideInputs = { common = ./.; };
        dir = "./examples/simple";
      };
    };
  };

}
