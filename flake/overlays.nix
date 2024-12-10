{ inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
  ];

  perSystem =
    { config, ... }:
    {
      overlayAttrs = {
        inherit (config.packages)
          neovim
          neovim-debug
          neovim-developer
          ;
      };
    };
}
