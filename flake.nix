{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    flake-utils,
    nixpkgs,
    self,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        selfPkgs = self.packages.${system};

        mkTarball = output: src: let
          inherit (src) version;
          pname = "${src.pname}-tarball";
        in
          pkgs.runCommand "${pname}-${src.version}" {
            inherit pname version src;
            nativeBuildInputs = [pkgs.gnutar];
          } ''
            WORKDIR="$PWD"
            cd $src
            tar czf "$WORKDIR/${output}.tar.gz" ./*
            mkdir -p $out/
            cp -av "$WORKDIR/${output}.tar.gz" $out/
          '';
      in {
        packages = {
          # Font with ligatures and normal spacing (some characters are double width).
          normal = pkgs.iosevka.override {
            set = "solai";
            privateBuildPlan = import ./iosevka.nix {
              family = "Iosevka Solai";
              spacing = "normal";
            };
          };

          # Font with ligatures and fixed spacing (all characters are single column).
          term = pkgs.iosevka.override {
            set = "solai-term";
            privateBuildPlan = import ./iosevka.nix {
              family = "Iosevka Solai Term";
              spacing = "term";
            };
          };

          all = pkgs.symlinkJoin {
            name = "iosevka-solai-all";
            paths = with selfPkgs; [normal term];
          };

          default = selfPkgs.all;

          # Used for generating tarballs for GitHub releases.
          tar-normal = mkTarball "iosevka-solai" selfPkgs.normal;
          tar-term = mkTarball "iosevka-solai-term" selfPkgs.term;
          tar = pkgs.symlinkJoin {
            name = "iosevka-solia-tarballs";
            paths = with selfPkgs; [tar-normal tar-term];
          };
        };

        formatter = pkgs.alejandra;
      }
    );
}
