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

          neovim = import ./neovim.nix {
            inherit (inputs) neovim-src;
            inherit lib pkgs neovim-dependencies;
            inherit (config.packages) tree-sitter;
          };

          neovim-debug = import ./neovim-debug.nix {
            inherit (config.packages) neovim;
            inherit pkgs;
          };

          neovim-developer = import ./neovim-developer.nix {
            inherit (config.packages) neovim-debug;
            inherit (inputs) neovim-src;
            inherit lib pkgs;
          };
        };
    };
}
