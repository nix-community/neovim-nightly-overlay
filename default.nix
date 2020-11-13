let
  sources = import ./nix/sources.nix;
  nixpkgs = sources."nixpkgs-unstable";
  pkgs = import nixpkgs { };

  # Needed until https://github.com/NixOS/nixpkgs/pull/102763 lands in nixpkgs-unstable
  tree-sitter = pkgs.tree-sitter.overrideAttrs (oldAttrs: {
    version = "0.17.3";
    sha256 = "sha256-uQs80r9cPX8Q46irJYv2FfvuppwonSS5HVClFujaP+U=";
    cargoSha256 = "sha256-fonlxLNh9KyEwCj7G5vxa7cM/DlcHNFbQpp0SwVQ3j4=";

    postInstall = ''
      PREFIX=$out make install
    '';

    buildInputs = oldAttrs.buildInputs
      ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [ pkgs.darwin.apple_sdk.frameworks.Security ];

    meta = oldAttrs.meta // { broken = false; };
  });
in
_: _:
{
  neovim-nightly = pkgs.neovim-unwrapped.overrideAttrs (
    old: {
      pname = "neovim-nightly";
      version = "master";
      src = sources.neovim;

      buildInputs = old.buildInputs ++ [ tree-sitter ];
    }
  );
}
