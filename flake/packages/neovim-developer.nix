{
  neovim-debug,
  neovim-unwrapped,
  pkgs,
  lib,
  stylua,
  stdenv,
  neovim-src,
  ...
}:
neovim-debug.overrideAttrs (oa: {
  pname = "${oa.pname}-developer";
  cmakeFlags =
    oa.cmakeFlags
    ++ [
      (lib.cmakeBool "ENABLE_LTO" false)
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      # https://github.com/google/sanitizers/wiki/AddressSanitizerFlags
      # https://clang.llvm.org/docs/AddressSanitizer.html#symbolizing-the-reports
      (lib.cmakeBool "ENABLE_ASAN_UBSAN" true)
    ];

  nativeBuildInputs = oa.nativeBuildInputs ++ [
    stylua
  ];

  doCheck = stdenv.isLinux;

  # This package can be "failing" as soon as a memory leak is detected
  ignoreFailure = true;
})
