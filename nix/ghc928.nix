{ inputs, ... }:
{
  perSystem = { pkgs, lib, config, ... }: {
    haskellProjects.ghc928 = {
      projectFlakeName = "euler-nix-common";

      # This is not a local project, so disable those options.
      defaults.packages = { };
      devShell.enable = false;
      autoWire = [ ];

      basePackages = pkgs.haskell.packages.ghc928-perf-events.override {
        all-cabal-hashes = builtins.fetchurl { url = "https://github.com/commercialhaskell/all-cabal-hashes/archive/f690741cb881620e902cb6077fe8032ff0a7cf63.tar.gz"; sha256 = "1354byy7h0zjkksimx013452k4iywcn3qq6pfrzwhxn28h03xgir"; };
      };

      imports = let common-inputs = inputs.common.inputs; in [
        common-inputs.spider.haskellFlakeProjectModules.output
      ];

      packages =
        let
          common-inputs = inputs.common.inputs;
        in
        {
          beam-core.source = common-inputs.beam + /beam-core;
          beam-migrate.source = common-inputs.beam + /beam-migrate;
          beam-mysql.source = common-inputs.beam-mysql;
          beam-postgres.source = common-inputs.beam + /beam-postgres;
          beam-sqlite.source = common-inputs.beam + /beam-sqlite;
          mysql-haskell.source = common-inputs.mysql-haskell;
          prometheus-client.source = common-inputs.prometheus-haskell + /prometheus-client;
          prometheus-proc.source = common-inputs.prometheus-haskell + /prometheus-proc;
          prometheus-metrics-ghc.source = common-inputs.prometheus-haskell + /prometheus-metrics-ghc;
          wai-middleware-prometheus.source = common-inputs.prometheus-haskell + /wai-middleware-prometheus;
          streamly-core.source = common-inputs.streamly-core + /core;
          streamly-serialize-instances.source = common-inputs.streamly-serialize-instances;
          tinylog.source = common-inputs.tinylog;
          word24.source = common-inputs.word24;
          jrec.source = common-inputs.jrec;
          servant.source = "0.19.1";
          servant-client.source = common-inputs.servant-client + /servant-client;
          servant-mock.source = common-inputs.servant-mock;
          hedis.source = common-inputs.hedis;
          cryptostore.source = "0.2.3.0";
          cereal.source = common-inputs.cereal;
          constraints-extras.source = "0.3.2.1";
          aeson.source = common-inputs.aeson-nau;
          servant-errors.source = common-inputs.servant-errors;
          amazonka.source = common-inputs.amazonka + /lib/amazonka;
          amazonka-core.source = common-inputs.amazonka + /lib/amazonka-core;
          amazonka-kms.source = common-inputs.amazonka + /lib/services/amazonka-kms;
          amazonka-sso.source = common-inputs.amazonka + /lib/services/amazonka-sso;
          amazonka-sts.source = common-inputs.amazonka + /lib/services/amazonka-sts;
          amazonka-test.source = common-inputs.amazonka + /lib/amazonka-test;
          amazonka-s3.source = common-inputs.amazonka + /lib/services/amazonka-s3;
          amazonka-ses.source = common-inputs.amazonka + /lib/services/amazonka-ses;
          amazonka-cloudfront.source = common-inputs.amazonka + /lib/services/amazonka-cloudfront;
          unordered-containers.source = "0.2.18.0";
          base32.source = "0.2.2.0";
          # country 0.2.3.1, the version packaged in the current version of nixpkgs requires atleast text 2.0
          country.source = "0.2.2";
          fast-time.source = common-inputs.fast-time;
          inline-js.source = common-inputs.inline-js-nau + /inline-js;
          inline-js-core.source = common-inputs.inline-js-nau + /inline-js-core;
          # pcre2 versions higher than this need text-2.0
          pcre2.source = "2.1.1.1";
          stan.source = "0.1.3.0";
        };

      settings = {
        sheriff.check = false;
        servant.jailbreak = true;
        servant-client.check = false;
        binary-parsers = {
          broken = false;
          jailbreak = true;
        };
        # primitive-checked is a dependency of `bytehash`, which is used in `euler-api-gateway`
        primitive-checked = {
          broken = false;
          jailbreak = true;
        };
        country.jailbreak = true;

        amazonka.jailbreak = true;

        jrec.cabalFlags.with-aeson = false;
        jrec.cabalFlags.with-generics = false;

        beam-mysql.cabalFlags.lenient = true;

        cryptonite.cabalFlags.support_aesni = false;

        word24.check = false;

        wire-streams.jailbreak = true;

        mysql-haskell.check = false;

        beam-postgres.check = false;

        bytestring-conversion.broken = false;
        aeson.check = false;
        aeson.jailbreak = true;
        aeson.cabalFlags.ordered-keymap = false;
        aeson-casing.check = false;
        lsp-types.check = false;
        # vector constraints aren't satisfied
        lrucaching = {
          broken = false;
          jailbreak = true;
        };

        # hspec and tdigest constraints aren't satisfied
        servant-client.jailbreak = true;

        # hspec constraints aren't satisfied
        servant-client-core.jailbreak = true;

        # hspec constraints aren't satisfied
        servant-server.jailbreak = true;

        servant-mock = {
          jailbreak = true;
          check = false;
        };

        # Tests assumes redis-server to be running
        hedis.check = false;

        stan = {
          jailbreak = true;
          check = false;
        };

      };

    };
  };
}
