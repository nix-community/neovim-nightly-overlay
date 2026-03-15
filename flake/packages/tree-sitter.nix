{
  lib,
  tree-sitter,
  clang,
  libclang,
  rustPlatform,
  neovim-dependencies,
}:
let
  cargoHash = "sha256-zh6KsnZ7s6VXGCggoYbLGeGnEZ7g7anjkz8C5/L4yXQ=";
in
tree-sitter.overrideAttrs (oa: {
  src = neovim-dependencies.treesitter;
  version = "bundled";
  inherit cargoHash;
  cargoDeps = rustPlatform.fetchCargoVendor {
    name = "${oa.pname}-cargo-deps";
    src = neovim-dependencies.treesitter;
    hash = cargoHash;
  };
  # Disable patches applied by the nixpkgs tree-sitter derivation as they clash with this revision of TS.
  # The equivalent patching is done below in `postPatch`
  patches = [ ];

  # clang is needed by the quickjs-sys crate to compile quickjs
  nativeBuildInputs = [
    clang
  ]
  ++ oa.nativeBuildInputs;
  env.LIBCLANG_PATH = "${lib.getLib libclang}/lib";

  postPatch = ''
    ${oa.postPatch}
    sed -e 's/playground::serve(.*$/println!("ERROR: web-ui is not available in this nixpkgs build; enable the webUISupport"); std::process::exit(1);/' \
        -i crates/cli/src/main.rs
  '';
})
