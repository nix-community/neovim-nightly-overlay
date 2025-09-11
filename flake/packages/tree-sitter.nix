{
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
          cargoHash = "sha256-0Do1UxIbfIfJ61dTiJt0ZGDrhOtGV0l9bafyoqcbqgU=";
        }
      );
  };
}).overrideAttrs
  (oa: {
    # Disable patches applied by the nixpkgs tree-sitter derivation as they clash with this revision of TS.
    # The equivalent patching is done below in `postPatch`
    patches = [ ];
    postPatch = ''
      ${oa.postPatch}
      sed -e 's/playground::serve(.*$/println!("ERROR: web-ui is not available in this nixpkgs build; enable the webUISupport"); std::process::exit(1);/' \
          -i cli/src/main.rs
    '';
  })
