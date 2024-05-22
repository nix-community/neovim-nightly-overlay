{
  neovim,
  pkgs,
  ...
}:
(neovim.override {
  stdenv =
    if pkgs.stdenv.isLinux
    then pkgs.llvmPackages_latest.stdenv
    else pkgs.stdenv;
  lua = pkgs.luajit;
})
.overrideAttrs (
  oa: {
    dontStrip = true;
    NIX_CFLAGES_COMPILE = " -ggdb -Og";
    cmakeBuildType = "Debug";
    disallowedReferences = [];
  }
)
