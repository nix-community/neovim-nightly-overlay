{inputs, ...}: {
  imports = [
    ./checks.nix
    ./ci.nix
    ./devshells.nix
    ./overlays.nix
    ./packages
    inputs.git-hooks.flakeModule
  ];

  perSystem = {pkgs, ...}: {
    formatter = pkgs.alejandra;
    pre-commit.settings.hooks.alejandra.enable = true;

    # Neovim uses lua 5.1 as it is the version which supports JIT
    _module.args = {
      lua = pkgs.luajit;
    };
  };
}
