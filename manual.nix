let
  pkgs = import <nixpkgs> {};

  mkNixosManual = let
    inherit pkgs;
    inherit (pkgs) lib;
    # Reduces the attrs from a package set so broken packages evaluate (I think?)
    scrubDerivations = namePrefix: pkgSet: lib.mapAttrs
      (name: value:
        let wholeName = "${namePrefix}.${name}"; in
        if lib.isAttrs value then
          scrubDerivations wholeName value
          // (lib.optionalAttrs (lib.isDerivation value) { outPath = "\${${wholeName}}"; })
        else value
      )
      pkgSet;
    # An evluation of the specified system version with only the modules and no config
    scrubbedEval = lib.evalModules {
      modules = [
      ./modules/hello.nix
      ./modules/taskserver/default.nix

      ];
      # modules = (import (./modules/hello.nix) { inherit lib; inherit pkgs;});
      # modules = [ ./modules/hello.nix];
      # modules = [
      #   (import (pkgs.path + /nixos/modules/misc/meta.nix) { inherit lib; })
      #   { meta  = {};
      #   meta.doc = ./.;
      # }
      # ];
      # # Forward the filtered package set and the modules path
      specialArgs = {
        pkgs = scrubDerivations "pkgs" pkgs;
        modulesPath = pkgs.path + /nixos/modules;
      };
    };
  in (import (pkgs.path + /nixos/doc/manual)) rec {
    # From parent scope
    inherit (scrubbedEval) config;
    # From let
    inherit pkgs;
    version = "0.0.1";
    revision = "release-${version}";

    # extraSources = [ ];
    options = scrubbedEval.options;
  };
in mkNixosManual

# das_j> pinpox: Du machst "einfach" `nix-build ./manual.nix -A manualHTML`, da gibts dann eine options.html
# 10:20 <das_j> eigene module kannst du in die auskommentierte imports zeile packen, extraSources musst du noch anpassen mit den ordnern (oder dem ordner) wo die module drin sind, sonst stimmen die links bei "Declared in" nicht 100%
