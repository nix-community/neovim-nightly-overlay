{ inputs, ... }:
{
  imports = [
    ./checks.nix
    ./ci.nix
    ./devshells.nix
    inputs.git-hooks.flakeModule
    inputs.treefmt-nix.flakeModule
  ];

  perSystem = {
    treefmt.config = {
      projectRootFile = "flake.nix";
      flakeCheck = true;

      programs = {
        nixfmt.enable = true;
      };
    };

    pre-commit.settings.hooks.treefmt.enable = true;
  };
}
