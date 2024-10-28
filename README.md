# To use the overlay

## with Flakes

If you are using [flakes] to configure your system, you can either reference the
package provided by this flake directly, e.g. for nixos:

```nix
{ inputs, pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
  };

  # or

  environment.systemPackages = [
    inputs.neovim-nightly-overlay.packages.${pkgs.system}.default
  ];
}
```

or you can apply the overlay to your package set, e.g for home-manager:

```nix
{
  inputs = {
    ...
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, ... }@inputs:
    let
      overlays = [
        inputs.neovim-nightly-overlay.overlays.default
      ];
    in
      homeConfigurations = {
        macbook-pro = inputs.home-manager.lib.homeManagerConfiguration {
          modules = [
            {
              nixpkgs.overlays = overlays;
            };
          ];
        };
      };
}
```

## without Flakes

Add the overlay to your home.nix (home-manager) or configuration.nix (nixos):

```nix
{
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = "https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz";
    }))
  ];
}
```
Due to some nixpkgs breaking changes if you are using NixOS 24.05 use the overlay below <br/>
*also requires that you have the nixpkgs-unstable `nix-channel`*
```nix
{
  nixpkgs.config = {
    packageOverrides = pkgs: let
      pkgs' = import <nixpkgs-unstable> {
        inherit (pkgs) system;
        overlays = [
          (import (builtins.fetchTarball {
            url = "https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz";
          }))
        ];
      };
    in {
      inherit (pkgs') neovim;
    };
  };
}
```

# Binary cache

See: https://app.cachix.org/cache/nix-community

[flakes]: https://wiki.nixos.org/wiki/Flakes
