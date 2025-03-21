{
  neovim,
  pkgs,
  ...
}:
(neovim.override {
  stdenv = if pkgs.stdenv.isLinux then pkgs.llvmPackages_latest.stdenv else pkgs.stdenv;
  lua = pkgs.luajit;
}).overrideAttrs
  (oa: {
    # Build neovim in debug mode
    NIX_CFLAGES_COMPILE = " -ggdb -Og";
    cmakeBuildType = "Debug";

    # Prevent nix from stripping debug symbols from the final binary
    dontStrip = false;

    # Do not explicitly disallow any paths to be referenced by the output
    # By default, the neovim derivation disallows any reference to the compiler.
    # https://github.com/NixOS/nixpkgs/blob/519502452f88c1e0b29ea6021fac0ce1640f4881/pkgs/by-name/ne/neovim-unwrapped/package.nix#L193
    disallowedRequisites = [ ];
  })
