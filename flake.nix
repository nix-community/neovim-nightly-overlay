{
  description = "Neovim flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts = { url = "github:hercules-ci/flake-parts"; inputs.nixpkgs-lib.follows = "nixpkgs"; };
    hercules-ci-effects = { url = "github:hercules-ci/hercules-ci-effects"; inputs.nixpkgs.follows = "nixpkgs"; };
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
    neovim-flake = { url = "github:neovim/neovim?dir=contrib"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } ({ config, ... }: {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
        inputs.hercules-ci-effects.flakeModule
      ];

      perSystem = { inputs', system, config, lib, pkgs, ... }: {
        packages = {
          neovim = (inputs'.neovim-flake.packages.neovim // (lib.optionalAttrs pkgs.stdenv.isDarwin { ignoreFailure = true; })).override {
            # TODO remove on the next staging -> master update
            inherit ((builtins.getFlake "github:NixOS/nixpkgs/d4758c3f27804693ebb6ddce2e9f6624b3371b08").legacyPackages.${system}) libvterm-neovim;
          };
          default = config.packages.neovim;
        };
        overlayAttrs = lib.genAttrs [ "neovim-unwrapped" "neovim-nightly" ] (_: config.packages.neovim);
      };

      flake = {
        defaultPackage = inputs.nixpkgs.lib.genAttrs config.systems (system: inputs.self.packages.${system}.default);
        overlay = inputs.self.overlays.default;
      };

      hercules-ci.flake-update = {
        enable = true;
        # Update everynight at midnight
        when = {
          hour = [ 0 ];
          minute = 0;
        };
      };
    });
}
