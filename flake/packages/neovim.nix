{
  neovim-src,
  lib,
  pkgs,
  ...
}: let
  src = pkgs.fetchFromGitHub {
    owner = "neovim";
    repo = "neovim";
    inherit (neovim-src) rev;
    hash = neovim-src.narHash;
  };

  deps = lib.pipe "${src}/cmake.deps/deps.txt" [
    builtins.readFile
    (lib.splitString "\n")
    (map (builtins.match "([A-Z0-0_]+)_(URL|SHA256)[[:space:]]+([^[:space:]]+)[[:space:]]*"))
    (lib.remove null)
    (lib.flip builtins.foldl' {}
      (acc: matches: let
        name = lib.toLower (builtins.elemAt matches 0);
        key = lib.toLower (builtins.elemAt matches 1);
        value = lib.toLower (builtins.elemAt matches 2);
      in
        acc
        // {
          ${name} =
            acc.${name}
            or {}
            // {
              ${key} = value;
            };
        }))
    (builtins.mapAttrs (lib.const pkgs.fetchurl))
  ];
in
  (pkgs.neovim-unwrapped.override {
    gettext = pkgs.gettext.overrideAttrs (_: {
      src = deps.gettext;
    });
    libiconv = pkgs.libiconv.overrideAttrs (_: {
      src = deps.libiconv;
    });
    libuv = pkgs.libuv.overrideAttrs (_: {
      src = deps.libuv;
    });
    libvterm-neovim = pkgs.libvterm-neovim.overrideAttrs (_: {
      src = deps.libvterm;
    });
    msgpack-c = pkgs.msgpack-c.overrideAttrs (_: {
      src = deps.msgpack;
    });
    tree-sitter = pkgs.tree-sitter.override (_: {
      rustPlatform =
        pkgs.rustPlatform
        // {
          buildRustPackage = args:
            pkgs.rustPlatform.buildRustPackage (args
              // {
                src = deps.treesitter;
                cargoHash = "sha256-U2YXpNwtaSSEftswI0p0+npDJqOq5GqxEUlOPRlJGmQ=";
              });
        };
    });
    treesitter-parsers = let
      grammars = lib.filterAttrs (name: _: lib.hasPrefix "treesitter_" name) deps;
      parsers =
        lib.mapAttrs'
        (name: value: lib.nameValuePair (lib.removePrefix "treesitter_" name) {src = value;})
        grammars;
    in
      parsers
      // {
        markdown = parsers.markdown // {location = "tree-sitter-markdown";};
        # TODO useless at some point (has been fixed in nixpkgs master)
        markdown_inline =
          parsers.markdown
          // {
            language = "markdown_inline";
            location = "tree-sitter-markdown-inline";
          };
      };
  })
  .overrideAttrs (oa: {
    version = "nightly";
    inherit src;
    preConfigure = ''
      ${oa.preConfigure}
      sed -i cmake.config/versiondef.h.in -e 's/@NVIM_VERSION_PRERELEASE@/-dev+${neovim-src.shortRev or "dirty"}/'
    '';
  })
