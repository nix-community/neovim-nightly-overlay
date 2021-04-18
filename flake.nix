{
  description = "Neovim nightly overlay";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.neovim-nightly = { url = "github:neovim/neovim"; flake = false; };

  outputs = { self, ... }@inputs:
    with inputs;
    {
      overlay = final: prev:
        let
          pkgs = inputs.nixpkgs.legacyPackages.${prev.system};
        in
        {
          neovim-nightly = pkgs.neovim-unwrapped.overrideAttrs (
            old: {
              pname = "neovim-nightly";
              version = "master";
              src = inputs.neovim-nightly;

              buildInputs = old.buildInputs ++ [ pkgs.tree-sitter ];
            }
          );
        };
    } //
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          overlays = [ self.overlay ];
          inherit system;
        };
      in
      {
        defaultPackage = pkgs.neovim-nightly;
      }
    );
}
