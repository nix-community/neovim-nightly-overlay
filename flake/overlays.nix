{inputs, ...}: {
  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
  ];

  perSystem = {
    inputs',
    system,
    config,
    lib,
    pkgs,
    ...
  }: {
    overlayAttrs = {
      inherit
        (config.packages)
        neovim
        neovim-debug
        neovim-developer
        ;
    };
  };
}
