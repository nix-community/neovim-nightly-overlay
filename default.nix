let
  sources = import ./nix/sources.nix;
  nixpkgs = sources."nixpkgs-unstable";
  pkgs = import nixpkgs { };
in
_: _:
{
  neovim-nightly = pkgs.neovim-unwrapped.overrideAttrs (
    old: {
      pname = "neovim-nightly";
      version = "master";
      src = sources.neovim;

      buildInputs = old.buildInputs ++ [ pkgs.tree-sitter ];
    }
  );
}
