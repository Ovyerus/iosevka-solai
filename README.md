# Iosevka Solai

Solai is a custom build of [Iosevka](https://github.com/be5invis/iosevka) for
personal use. Mostly an extension of the "curvy" preset, with other variants
chosen as I see fit.

## Usage

In most cases you will want to fetch the tarball from the latest
[GitHub release](https://github.com/Ovyerus/iosevka-solai/releases) and manually
install from them.

If you use Nix with either [NixOS](https://nixos.org) or
[nix-darwin](https://github.com/LnL7/nix-darwin), this repository is available
to use as a flake.

(Font compilation will take a very long time depending on the amount of cores in
your system. I'm looking into providing binary caches.)

### NixOS

```nix
{
  inputs = {
    # Whatever channel your system is already using.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    iosevka-solai = {
      url = "github:Ovyerus/iosevka-solai";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    iosevka-solai,
    ...
  }: {
    nixosConfigurations."hostname" = nixpkgs.lib.nixosSystem {
      system = "...";
      modules = [
        ({...}: {
          # 23.05 and below
          fonts.fonts = [iosevka-solai.packages.${system}.default];
          # 23.11 and above
          fonts.packages = [iosevka-solai.packages.${system}.default];
        })
      ];
    };
  };
}

```

### nix-darwin

```nix
{
  inputs = {
    # Whatever channel your system is already using.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    iosevka-solai = {
      url = "github:Ovyerus/iosevka-solai";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  output = {
    nix-darwin,
    nixpkgs,
    iosevka-solai,
    ...
  }: {
    darwinConfigurations."hostname" = nix-darwin.lib.darwinSystem {
      modules = [
        ({...}: {
          fonts.fontDir.enable = true;
          fonts.fonts = [
            iosevka.packages.${system}.default
          ];
        })
      ];
    };
  };
}

```

---

Iosevka is licensed under the
[SIL Open Font License 1.1](https://github.com/be5invis/Iosevka/blob/main/LICENSE.md).
The code in this repostiory is licensed under the [Zlib license](./LICENSE).
