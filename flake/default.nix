{
  inputs,
  config,
  lib,
  ...
}:
{
  imports = [
    inputs.flake-parts.flakeModules.partitions
    ./overlays.nix
    ./packages
  ];

  # Include the public package independently of the dev-partition checks.
  flake.ciJobs = {
    inherit (config.flake) checks;
    packages = lib.mapAttrs (_system: packages: { inherit (packages) default; }) config.flake.packages;
  };

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
