{
  neovim-debug,
  pkgs,
  lib,
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
    pkgs.stylua
  ];

  doCheck = pkgs.stdenv.isLinux;

  shellHook = ''
    ${oa.shellHook or ""}
    export ASAN_SYMBOLIZER_PATH=${pkgs.llvm_18}/bin/llvm-symbolizer

    # ASAN_OPTIONS=detect_leaks=1
    export ASAN_OPTIONS="log_path=./test.log:abort_on_error=1"
  '';
  # This package can be "failing" as soon as a memory leak is detected
  ignoreFailure = true;
})
