{
  description = "Neovim flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    neovim-flake.url = "github:neovim/neovim?dir=contrib";
    neovim-flake.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, neovim-flake }:
    rec {
      inherit (neovim-flake) packages defaultPackage apps defaultApp devShell;
      overlay = final: prev: {
        final.neovim-unwrapped = packages.neovim;
        final.neovim-nightly = packages.neovim;
        final.neovim-debug = packages.neovim-debug;
        final.neovim-developer = packages.neovim-developer;
      };
    };
}
