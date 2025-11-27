{
  lib,
  pkgs,
  neovim-dependencies,
}:
(pkgs.tree-sitter.override {
  rustPlatform = pkgs.rustPlatform // {
    buildRustPackage =
      args:
      pkgs.rustPlatform.buildRustPackage (
        args
        // {
          version = "bundled";
          src = neovim-dependencies.treesitter;
          cargoHash = "sha256-hdjHU9zAo320XSp0oIXUsGMyoVBAJrjvgzQqXO4DpUM=";
        }
      );
  };
}).overrideAttrs
  (oa: {
    # Disable patches applied by the nixpkgs tree-sitter derivation as they clash with this revision of TS.
    # The equivalent patching is done below in `postPatch`
    patches = [ ];

    # clang is needed by the quickjs-sys crate to compile quickjs
    nativeBuildInputs = [
      pkgs.clang
    ]
    ++ oa.nativeBuildInputs;
    env.LIBCLANG_PATH = "${lib.getLib pkgs.libclang}/lib";

    postPatch = ''
      ${oa.postPatch}
      sed -e 's/playground::serve(.*$/println!("ERROR: web-ui is not available in this nixpkgs build; enable the webUISupport"); std::process::exit(1);/' \
          -i crates/cli/src/main.rs
    '';
  })
