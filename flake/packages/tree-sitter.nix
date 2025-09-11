{
  neovim-src,
  pkgs,
  lib,
  ...
}:
let
  deps = lib.pipe "${neovim-src}/cmake.deps/deps.txt" [
    builtins.readFile
    (lib.splitString "\n")
    (map (builtins.match "([A-Z0-9_]+)_(URL|SHA256)[[:space:]]+([^[:space:]]+)[[:space:]]*"))
    (lib.remove null)
    (lib.flip builtins.foldl' { } (
      acc: matches:
      let
        name = lib.toLower (builtins.elemAt matches 0);
        key = lib.toLower (builtins.elemAt matches 1);
        value = lib.toLower (builtins.elemAt matches 2);
      in
      acc
      // {
        ${name} = acc.${name} or { } // {
          ${key} = value;
        };
      }
    ))
    (builtins.mapAttrs (lib.const pkgs.fetchurl))
  ];

in
(pkgs.tree-sitter.override {
  rustPlatform = pkgs.rustPlatform // {
    buildRustPackage =
      args:
      pkgs.rustPlatform.buildRustPackage (
        args
        // {
          version = "bundled";
          src = deps.treesitter;
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
