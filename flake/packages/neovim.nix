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

  # The following overrides will only take effect for linux hosts
  linuxOnlyOverrides = lib.optionalAttrs (!pkgs.stdenv.isDarwin) {
    gettext = pkgs.gettext.overrideAttrs {
      src = deps.gettext;
    };

    # pkgs.libiconv.src is pointing at the darwin fork of libiconv.
    # Hence, overriding its source does not make sense on darwin.
    libiconv = pkgs.libiconv.overrideAttrs {
      src = deps.libiconv;
    };
  };

  overrides =
    {
      # FIXME: this has been causing problems, see;
      # https://github.com/nix-community/neovim-nightly-overlay/issues/538
      # libuv = pkgs.libuv.overrideAttrs {
      #   src = deps.libuv;
      # };
      libvterm-neovim = pkgs.libvterm-neovim.overrideAttrs {
        src = deps.libvterm;
      };
      lua = pkgs.luajit;
      msgpack-c = pkgs.msgpack-c.overrideAttrs {
        src = deps.msgpack;
      };
      tree-sitter = pkgs.tree-sitter.override {
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
      };
      treesitter-parsers = let
        grammars = lib.filterAttrs (name: _: lib.hasPrefix "treesitter_" name) deps;
      in
        lib.mapAttrs'
        (
          name: value:
            lib.nameValuePair
            (lib.removePrefix "treesitter_" name)
            {src = value;}
        )
        grammars;
    }
    // linuxOnlyOverrides;
in
  (
    pkgs.neovim-unwrapped.override
    overrides
  )
  .overrideAttrs (oa: {
    version = "nightly";
    inherit src;
    preConfigure = ''
      ${oa.preConfigure}
      sed -i cmake.config/versiondef.h.in -e 's/@NVIM_VERSION_PRERELEASE@/-dev+${neovim-src.shortRev or "dirty"}/'
    '';
  })
