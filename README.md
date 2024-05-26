# To use the overlay

---
**Matrix room:** [#neovim-nightly-overlay:nixos.org](https://matrix.to/#/#neovim-nightly-overlay:nixos.org)

---

Add the overlay to your home.nix (home-manager) or configuration.nix (nixos):

```nix
{
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    }))
  ];
}
```

If you are using flakes to configure your system, add to your nixpkgs overlays attribute (examples will differ, the following is for home-manager):

```nix
{
  inputs.neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  outputs = { self, ... }@inputs:
    let
      overlays = [
          inputs.neovim-nightly-overlay.overlay
        ];
    in
      homeConfigurations = {
        macbook-pro = inputs.home-manager.lib.homeManagerConfiguration {
          configuration = { pkgs, ... }:
            {
              nixpkgs.overlays = overlays;
            };
        };
      };
}
```

Note, I recently switched the overlay to use flakes by default with flakes-compat for older nix. Please report issues if this breaks things.

Install neovim:
```
nix-env -iA pkgs.neovim
```
or add to home-manager/configuration.nix.

Install with nix profile:
```
nix profile --substituters https://nix-community.cachix.org --trusted-public-keys nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= install github:nix-community/neovim-nightly-overlay#neovim
```

# Binary cache

You will want to use the [nix-community binary cache](https://nix-community.org/#binary-cache). Where the
overlay's build artefacts are pushed. See [here](https://app.cachix.org/cache/nix-community) for installation
instructions.
