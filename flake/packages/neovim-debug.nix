{
  neovim,
  stdenv,
  llvmPackages_latest,
  ...
}:
(neovim.override {
  stdenv = if stdenv.isLinux then llvmPackages_latest.stdenv else stdenv;
}).overrideAttrs
  (oa: {
    # Build neovim in debug mode
    NIX_CFLAGES_COMPILE = " -ggdb -Og";
    cmakeBuildType = "Debug";

    # Prevent nix from stripping debug symbols from the final binary
    dontStrip = true;

    # Do not explicitly disallow any paths to be referenced by the output
    # By default, the neovim derivation disallows any reference to the compiler.
    # https://github.com/NixOS/nixpkgs/blob/519502452f88c1e0b29ea6021fac0ce1640f4881/pkgs/by-name/ne/neovim-unwrapped/package.nix#L193
    disallowedRequisites = [ ];
  })
