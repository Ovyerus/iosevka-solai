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

        fetchGitHubFont = {
          name,
          url,
          hash,
        }:
          pkgs.stdenv.mkDerivation {
            inherit name;
            src = pkgs.fetchzip {inherit url hash;};
            phases = ["installPhase" "patchPhase"];
            installPhase = ''
              mkdir -p $out/share
              cp -r $src/fonts $out/share/
            '';
          };
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

          # Pull from GitHub Releases, for those who don't want to build from scratch
          bin-normal = fetchGitHubFont {
            name = "iosevka-solai-normal-bin";
            url = "https://github.com/Ovyerus/iosevka-solai/releases/download/v2.0.0/iosevka-solai.tar.gz";
            hash = "sha256-6gFYlB7Pl54Au/7pfuTH4f66T9WnvI7sDHW4ulZBSlk=";
          };
          bin-term = fetchGitHubFont {
            name = "iosevka-solai-term-bin";
            url = "https://github.com/Ovyerus/iosevka-solai/releases/download/v2.0.0/iosevka-solai-term.tar.gz";
            hash = "sha256-tB6klrC7VG/hvh7LzhsxxjstMITrTCmUnFnVFuSCpE0=";
          };
          bin = pkgs.symlinkJoin {
            name = "iosevka-solai-bin";
            paths = with selfPkgs; [bin-normal bin-term];
          };
        };

        formatter = pkgs.alejandra;
      }
    );
}
