{
  inputs,
  lib,
  ...
}: {
  imports =
    [
      ./checks.nix
      ./ci.nix
      ./devshells.nix
      ./overlays.nix
      ./packages
    ]
    ++ lib.optionals (inputs.git-hooks ? flakeModule) [inputs.git-hooks.flakeModule];

  perSystem = {pkgs, ...}:
    {
      formatter = pkgs.alejandra;
    }
    // lib.optionalAttrs (inputs.git-hooks ? flakeModule) {
      pre-commit.settings.hooks.alejandra.enable = true;
    };
}
