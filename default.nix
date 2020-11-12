let
  sources = import ./nix/sources.nix;
  nixpkgs = sources."nixpkgs-unstable";
  pkgs = import nixpkgs { };
in
_: _:
{
  neovim-nightly = pkgs.neovim-unwrapped.overrideAttrs (oldAttrs: {
    pname = "neovim-nightly";
    version = "master";
    src = sources.neovim;

    buildInputs = oldAttrs.buildInputs ++ [ pkgs.tree-sitter ];
  });
}
