{
  neovim-debug,
  pkgs,
  lib,
  neovim-src,
  ...
}:
neovim-debug.overrideAttrs (oa: {
  cmakeFlagsArray =
    oa.cmakeFlagsArray
    ++ [
      "-DLUACHECK_PRG=${pkgs.luajit.pkgs.luacheck}/bin/luacheck"
      "-DENABLE_LTO=OFF"
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      # https://github.com/google/sanitizers/wiki/AddressSanitizerFlags
      # https://clang.llvm.org/docs/AddressSanitizer.html#symbolizing-the-reports
      "-DENABLE_ASAN_UBSAN=ON"
    ];
  doCheck = pkgs.stdenv.isLinux;
  shellHook = ''
    export VIMRUNTIME=${neovim-src}/runtime
  '';

  # This package can be "failing" as soon as a memory leak is detected
  ignoreFailure = true;
})
