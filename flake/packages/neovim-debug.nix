{
  neovim,
  stdenv,
  llvmPackages_latest,
  lib,
  ...
}:
(neovim.override {
  stdenv = if stdenv.isLinux then llvmPackages_latest.stdenv else stdenv;
}).overrideAttrs
  (oa: {
    pname = "${oa.pname}-debug";

    # Build neovim in debug mode
    NIX_CFLAGES_COMPILE = " -ggdb -Og";
    cmakeBuildType = "Debug";
    cmakeFlags = oa.cmakeFlags ++ [
      (lib.cmakeFeature "CMAKE_EXTRA_FLAGS" "-DNVIM_LOG_DEBUG=ON")
    ];

    # Prevent nix from stripping debug symbols from the final binary
    dontStrip = true;

    shellHook = ''
      # doesnt do anything
      PATH="$PWD/build/bin:$PATH"
      if [ -d "$PWD/runtime" ]; then
        export VIMRUNTIME="$PWD/runtime"
        echo "Detecting neovim runtime folder: VIMRUNTIME set to $VIMRUNTIME"
      fi
      echo "export NVIM_LOG_FILE to where you want to save the log"
      export NVIM_LOG_FILE="$PWD/nvim.log"
    '';

    # Do not explicitly disallow any paths to be referenced by the output
    # By default, the neovim derivation disallows any reference to the compiler.
    # https://github.com/NixOS/nixpkgs/blob/519502452f88c1e0b29ea6021fac0ce1640f4881/pkgs/by-name/ne/neovim-unwrapped/package.nix#L193
    disallowedRequisites = [ ];
  })
