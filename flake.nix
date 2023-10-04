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

      perSystem = { inputs', config, lib, ... }: {
        packages = {
          inherit (inputs'.neovim-flake.packages) neovim;
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
        createPullRequest = false;
        updateBranch = "master";
        # Update everynight at midnight
        when = {
          hour = [ 0 ];
          minute = 0;
        };
      };
    });
}
