# To use the overlay

> [!IMPORTANT]
> When using this overlay, you might encounter `error: hash mismatch in fixed-output derivation '/nix/store/...-tree-sitter-bundled-vendor-staging.drv'`.\
> The issue is that `neovim-nightly-overlay` uses and overrides the `treesitter` **from your own package set**. If this `treesitter` is different than the one we expect, you might get a hash mismatch.\
> To work around this, you can either:
>
> - Do not use this flake as an overlay, but simply get its default package output (`inputs.neovim-nightly.packages.${system}.default`)
> - Override `treesitter` with your own version: `pkgs.neovim.override ...`


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
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, ... }@inputs:
    let
      overlays = [
        inputs.neovim-nightly-overlay.overlays.default
      ];
    in
    {
      homeConfigurations = {
        macbook-pro = inputs.home-manager.lib.homeManagerConfiguration {
          modules = [
            {
              nixpkgs.overlays = overlays;
            }
          ];
        };
      };
    };
}
```

### Updating

The `neovim-nightly-overlay` flake itself is updated every day to use the latest `neovim` source code.

However, your own flake needs to be synced **manually**. Remember to regularly update your flake (e.g. by using `nix flake update`) to get a most recent neovim build.

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
