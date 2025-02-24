{ inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
  ];

  perSystem =
    { config, ... }:
    {
      overlayAttrs = {
        neovim-unwrapped = config.packages.neovim;
        inherit (config.packages)
          neovim
          neovim-debug
          neovim-developer
          ;
      };
    };
}
