{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    flake-utils,
    nixpkgs,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        packages = {
          normal = pkgs.iosevka.override {
            set = "solai";
            privateBuildPlan = import ./iosevka.nix {
              family = "Iosevka Solai";
              spacing = "normal";
            };
          };

          term = pkgs.iosevka.override {
            set = "solai-term";
            privateBuildPlan = import ./iosevka.nix {
              family = "Iosevka Solai Term";
              spacing = "term";
            };
          };
        };

        formatter = pkgs.alejandra;
      }
    );
}
