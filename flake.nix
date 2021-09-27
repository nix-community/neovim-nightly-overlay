{
  description = "Neovim flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
    neovim-flake.url = "github:neovim/neovim?dir=contrib";
    neovim-flake.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, neovim-flake, ... }:
    rec {
      inherit (neovim-flake) packages defaultPackage apps defaultApp devShell;
      overlay = final: prev: let
        pkgs = "${prev.system}".pkgs;
      in {
        neovim-unwrapped = neovim-flake.packages.${prev.system}.neovim;
        neovim-nightly = neovim-flake.packages.${prev.system}.neovim;
        neovim-debug = neovim-flake.packages.${prev.system}.neovim-debug;
        neovim-developer = neovim-flake.packages.${prev.system}.neovim-developer;

        # nixpkgs pins plugins to work with their matching neovim version
        # this tries to get the latest version of the plugins so that they work
        # with neovim master
        vimPluginsForNeovimMaster = pkgs.callPackage ./vim-plugins/generated.nix {
          inherit (pkgs.vimUtils) buildVimPluginFrom2Nix;
        };
      };
    };
}
