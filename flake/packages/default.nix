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
          neovim-dependencies = pkgs.callPackage ./neovim-dependencies.nix {
            inherit (inputs) neovim-src;
          };
        in
        {
          default = config.packages.neovim;

          tree-sitter = pkgs.callPackage ./tree-sitter.nix {
            inherit neovim-dependencies;
          };

          neovim = pkgs.callPackage ./neovim.nix {
            inherit (inputs) neovim-src;
            inherit neovim-dependencies;
            inherit (config.packages) tree-sitter;
            baseNeovimUnwrapped = pkgs.neovim-unwrapped;
          };

          neovim-debug = pkgs.callPackage ./neovim-debug.nix {
            inherit (config.packages) neovim;
          };

          neovim-developer = pkgs.callPackage ./neovim-developer.nix {
            inherit (config.packages) neovim-debug;
            inherit (inputs) neovim-src;
          };
        };
    };
}
