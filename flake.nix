{
  description = "Neovim flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
    neovim-flake.url = "github:neovim/neovim?dir=contrib";
    neovim-flake.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, neovim-flake, ... }:
    let forAllSystems = (nixpkgs.lib.genAttrs [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ]); in
    {
      packages = forAllSystems (system: { inherit (neovim-flake.packages.${system}) default neovim; });
      defaultPackage = forAllSystems (system: neovim-flake.packages.${system}.default);
      overlay = final: prev: {
        neovim-unwrapped = self.packages.${prev.system}.neovim;
        neovim-nightly = self.packages.${prev.system}.neovim;
      };
      herculesCI = {
        ciSystems = [ "x86_64-linux" "aarch64-linux" ]; # These are the only systems avaiable currently for our Hercules-CI infra.
      };
    };
}
