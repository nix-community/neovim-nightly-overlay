let
  sources = import ./nix/sources.nix;
  nixpkgs = sources."nixpkgs-unstable";
  pkgs = import nixpkgs {};
in
_: _:
  {
    neovim-nightly = pkgs.neovim-unwrapped.overrideAttrs (
      _: {
        pname = "neovim-nightly";
        version = "master";
        src = pkgs.fetchFromGitHub {
          inherit (sources.neovim) owner repo rev sha256;
        };
      }
    );
  }
