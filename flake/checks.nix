{
  perSystem = {
    pkgs,
    config,
    ...
  }: {
    checks = {
      # Not checking neovim-developer here as it currently failes because of memory leaks
      inherit (config.packages) neovim;
    };
  };
}
