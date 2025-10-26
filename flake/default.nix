{ inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.partitions
    ./overlays.nix
    ./packages
  ];

  partitionedAttrs = {
    checks = "dev";
    devShells = "dev";
    formatter = "dev";
    herculesCI = "dev";
  };

  partitions.dev = {
    extraInputsFlake = ./dev;
    module = ./dev;
  };
}
