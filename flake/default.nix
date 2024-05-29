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
  };
}
