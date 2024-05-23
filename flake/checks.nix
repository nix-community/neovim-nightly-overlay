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

      inherit
        (config.packages)
        neovim
        neovim-debug
        neovim-developer
        ;
    };
  };
}
