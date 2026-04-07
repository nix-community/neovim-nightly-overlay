{ inputs, ... }:
{
  perSystem =
    {
      inputs',
      system,
      config,
      lib,
      pkgs,
      ...
    }:
    {
      packages =
        let
          neovim-dependencies = import ./neovim-dependencies.nix {
            inherit (inputs) neovim-src;
            inherit lib pkgs;
          };
        in
        {
          default = config.packages.neovim;

          tree-sitter = import ./tree-sitter.nix {
            inherit lib pkgs neovim-dependencies;
          };

          # NOTE: We use "import" instead of "callPackage" for neovim variants to keep the original "override" interface, ie, a user shall should be able to override neovim-debug like he overrides neovim-unwrapped
          # This may change after https://github.com/NixOS/nixpkgs/pull/455805
          neovim = import ./neovim.nix {
            inherit (inputs) neovim-src;
            inherit lib pkgs neovim-dependencies;
            inherit (config.packages) tree-sitter;
          };

          neovim-debug = import ./neovim-debug.nix {
            inherit (config.packages) neovim;
            inherit (pkgs) stdenv llvmPackages_latest;
            inherit lib;
          };

          neovim-developer = import ./neovim-developer.nix {
            inherit (config.packages) neovim-debug;
            inherit (inputs) neovim-src;
            inherit lib pkgs;
          };
        };
    };
}
