# To use the overlay

## with Flakes

If you are using [flakes] to configure your system, you can either reference the
package provided by this flake directly, e.g. for nixos:

```nix
{ inputs, pkgs, ... }:
{
  progams.neovim = {
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

# Binary cache

See: https://app.cachix.org/cache/nix-community

[flakes]: https://nixos.wiki/wiki/Flakes
