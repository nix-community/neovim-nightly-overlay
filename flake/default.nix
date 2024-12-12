{
  inputs,
  lib,
  ...
}:
{
  imports =
    [
      ./checks.nix
      ./ci.nix
      ./devshells.nix
      ./overlays.nix
      ./packages
    ]
    ++ lib.optionals (inputs.git-hooks ? flakeModule) [ inputs.git-hooks.flakeModule ]
    ++ lib.optionals (inputs.treefmt-nix ? flakeModule) [ inputs.treefmt-nix.flakeModule ];

  perSystem =
    { pkgs, ... }:
    lib.optionalAttrs (inputs.treefmt-nix ? flakeModule) {
      treefmt.config = {
        projectRootFile = "flake.nix";
        flakeCheck = true;

        programs = {
          nixfmt.enable = true;
        };
      };
    }
    // lib.optionalAttrs (inputs.git-hooks ? flakeModule) {
      pre-commit.settings.hooks.treefmt.enable = true;
    };
}
