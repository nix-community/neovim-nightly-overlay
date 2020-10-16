let
  sources = import ./nix/sources.nix;
  nixpkgs = sources."nixpkgs-unstable";
  neovim-nightly-overlay = import ./default.nix;
  pkgs = import nixpkgs { config = { }; overlays = [ neovim-nightly-overlay ]; };
in
{
  neovim-nightly = pkgs.neovim-nightly;
}
