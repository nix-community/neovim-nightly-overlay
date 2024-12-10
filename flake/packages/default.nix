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
      packages = {
        default = config.packages.neovim;

        neovim = import ./neovim.nix {
          inherit (inputs) neovim-src;
          inherit lib pkgs;
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
