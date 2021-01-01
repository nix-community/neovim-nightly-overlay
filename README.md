# To use the overlay 

Add the following to your home.nix (home-manager) or configuration.nix (nixos):

```nix
{
nixpkgs.overlays = [ 
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    }))
   ];
}
```

If usings flakes, add to your nixpkgs overlays attribute (examples will differ, the following is for home-manager):
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

Install neovim-nightly:
```
nix-env -iA pkgs.neovim-nightly
```
or add to home-manager/configuration.nix.

# Binary cache

You will want to use the [nix-community binary cache](https://nix-community.org/#binary-cache). Where the
overlay's build artefacts are pushed. See [here](https://app.cachix.org/cache/nix-community) for installation
instructions.
