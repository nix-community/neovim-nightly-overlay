{inputs, ...}: {
  perSystem = {
    pkgs,
    config,
    ...
  }: {
    checks = {
      # TODO: not working: remove ?
      # shlint = pkgs.runCommand "shlint" {
      #   nativeBuildInputs = [pkgs.shellcheck];
      #   preferLocalBuild = true;
      # } "make -C ${inputs.neovim-src} shlint > $out";

      # Not checking neovim-developer here as it currently failes because of memory leaks
      inherit
        (config.packages)
        neovim
        neovim-debug
        ;
    };
  };
}
