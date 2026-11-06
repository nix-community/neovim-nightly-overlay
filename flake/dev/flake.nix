{
  description = "Private inputs for development purposes. These are used by the top level flake in the `dev` partition, but do not appear in consumers' lock files.";

  inputs = {
    root.url = "path:../..";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    hercules-ci-effects = {
      url = "github:hercules-ci/hercules-ci-effects";
      inputs.flake-parts.follows = "root/flake-parts";
      inputs.nixpkgs.follows = "root/nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.flake-compat.follows = "flake-compat";
      inputs.nixpkgs.follows = "root/nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "root/nixpkgs";
    };
  };

  # This flake is only used for its inputs.
  outputs = _: { };
}
