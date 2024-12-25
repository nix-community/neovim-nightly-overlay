{
  neovim-src,
  lib,
  pkgs,
  ...
}:
let
  src = neovim-src;

  deps = lib.pipe "${src}/cmake.deps/deps.txt" [
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

  # The following overrides will only take effect for linux hosts
  linuxOnlyOverrides = lib.optionalAttrs pkgs.stdenv.isLinux {
    gettext = pkgs.gettext.overrideAttrs {
      src = deps.gettext;
    };
  };

  overrides = {
    # FIXME: this has been causing problems, see;
    # https://github.com/nix-community/neovim-nightly-overlay/issues/538
    # libuv = pkgs.libuv.overrideAttrs {
    #   src = deps.libuv;
    # };
    lua = pkgs.luajit;
    tree-sitter =
      (pkgs.tree-sitter.override {
        rustPlatform = pkgs.rustPlatform // {
          buildRustPackage =
            args:
            pkgs.rustPlatform.buildRustPackage (
              args
              // {
                version = "bundled";
                src = deps.treesitter;
                cargoHash = "sha256-i2/VTf/QEWUhFFpDJi94Eui9wFW4J3ziUoIcxVQN+PI=";
              }
            );
        };
      }).overrideAttrs
        (oa: {
          postPatch = ''
            ${oa.postPatch}
            sed -e 's/playground::serve(.*$/println!("ERROR: web-ui is not available in this nixpkgs build; enable the webUISupport"); std::process::exit(1);/' \
                -i cli/src/main.rs
          '';
        });

    treesitter-parsers =
      let
        grammars = lib.filterAttrs (name: _: lib.hasPrefix "treesitter_" name) deps;
      in
      lib.mapAttrs' (
        name: value: lib.nameValuePair (lib.removePrefix "treesitter_" name) { src = value; }
      ) grammars;
  } // linuxOnlyOverrides;
in
(pkgs.neovim-unwrapped.override overrides).overrideAttrs (oa: {
  version = "nightly";
  inherit src;

  preConfigure = ''
    ${oa.preConfigure}
    substituteInPlace cmake.config/versiondef.h.in \
      --replace-fail '@NVIM_VERSION_PRERELEASE@' '-nightly+${neovim-src.shortRev or "dirty"}'
  '';

  buildInputs =
    with pkgs;
    [
      # TODO: remove once upstream nixpkgs updates the base drv
      (utf8proc.overrideAttrs (_: {
        src = deps.utf8proc;
      }))
    ]
    ++ oa.buildInputs;
})
