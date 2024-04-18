{
  description = "Neovim flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    neovim-src = {
      url = "github:neovim/neovim";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      neovim-src,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          overlays = [ self.overlays.default ];
          inherit system;
        };

        lua = pkgs.lua5_1;

        pythonEnv = pkgs.python3.withPackages (ps: [ ps.msgpack ]);
      in
      {
        packages = with pkgs; {
          default = neovim;
          inherit neovim neovim-debug neovim-developer;
        };

        checks = {
          shlint = pkgs.runCommand "shlint" {
            nativeBuildInputs = [ pkgs.shellcheck ];
            preferLocalBuild = true;
          } "make -C ${neovim-src} shlint > $out";
        };

        devShells = {
          default = pkgs.neovim-developer.overrideAttrs (oa: {

            buildInputs =
              with pkgs;
              oa.buildInputs
              ++ [
                lua.pkgs.luacheck
                sumneko-lua-language-server
                pythonEnv
                include-what-you-use # for scripts/check-includes.py
                jq # jq for scripts/vim-patch.sh -r
                shellcheck # for `make shlint`
              ];

            nativeBuildInputs =
              with pkgs;
              oa.nativeBuildInputs
              ++ [
                clang-tools # for clangd to find the correct headers
              ];

            shellHook =
              oa.shellHook
              + ''
                export NVIM_PYTHON_LOG_LEVEL=DEBUG
                export NVIM_LOG_FILE=/tmp/nvim.log
                export ASAN_SYMBOLIZER_PATH=${pkgs.llvm_18}/bin/llvm-symbolizer

                # ASAN_OPTIONS=detect_leaks=1
                export ASAN_OPTIONS="log_path=./test.log:abort_on_error=1"

                # for treesitter functionaltests
                mkdir -p runtime/parser
                cp -f ${pkgs.vimPlugins.nvim-treesitter.builtGrammars.c}/parser runtime/parser/c.so
              '';
          });
        };
      }
    )
    // {
      overlays.default =
        final: prev:
        let
          inherit (final) lib;
          deps = lib.pipe "${neovim-src}/cmake.deps/deps.txt" [
            builtins.readFile
            (lib.splitString "\n")
            (map (builtins.match "([A-Z0-0_]+)_(URL|SHA256)[[:space:]]+([^[:space:]]+)[[:space:]]*"))
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
            (builtins.mapAttrs (lib.const final.fetchurl))
          ];
          tree-sitter = final.tree-sitter.override (_: {
            rustPlatform = final.rustPlatform // {
              buildRustPackage =
                args:
                final.rustPlatform.buildRustPackage (
                  args
                  // {
                    src = deps.treesitter;
                    cargoHash = "sha256-U2YXpNwtaSSEftswI0p0+npDJqOq5GqxEUlOPRlJGmQ=";
                  }
                );
            };
          });

          treesitter-parsers =
            let
              grammars = lib.filterAttrs (name: _: lib.hasPrefix "treesitter_" name) deps;
              parsers = lib.mapAttrs' (
                name: value: lib.nameValuePair (lib.removePrefix "treesitter_" name) { src = value; }
              ) grammars;
            in
            parsers
            // {
              markdown = parsers.markdown // {
                location = "tree-sitter-markdown";
              };
              markdown-inline = parsers.markdown // {
                language = "markdown_inline";
                location = "tree-sitter-markdown-inline";
              };
            };
        in
        {

          neovim =
            (final.neovim-unwrapped.override {
              inherit tree-sitter;
              inherit treesitter-parsers;
              msgpack-c = final.msgpack-c.overrideAttrs (_: {
                src = deps.msgpack;
              });
              gettext = final.gettext.overrideAttrs (_: {
                src = deps.gettext;
              });
              libiconv = final.libiconv.overrideAttrs (_: {
                src = deps.libiconv;
              });
              libuv = final.libuv.overrideAttrs (_: {
                src = deps.libuv;
              });
              libvterm-neovim = final.libvterm-neovim.overrideAttrs (_: {
                src = deps.libvterm;
              });
            }).overrideAttrs
              (
                oa:
                let
                  version = neovim-src.shortRev or "dirty";
                in
                {

                  src = "${neovim-src}";
                  preConfigure =
                    oa.preConfigure or ""
                    + ''
                      sed -i cmake.config/versiondef.h.in -e 's/@NVIM_VERSION_PRERELEASE@/-dev-${version}/'
                    '';
                  nativeBuildInputs = oa.nativeBuildInputs ++ [ final.libiconv ];
                }
              );

          # a development binary to help debug issues
          neovim-debug =
            let
              stdenv = if final.stdenv.isLinux then final.llvmPackages_latest.stdenv else final.stdenv;
            in
            (final.neovim.override {
              lua = final.luajit;
              inherit stdenv;
            }).overrideAttrs
              (oa: {

                dontStrip = true;
                NIX_CFLAGS_COMPILE = " -ggdb -Og";

                cmakeBuildType = "Debug";

                disallowedReferences = [ ];
              });

          # for neovim developers, beware of the slow binary
          neovim-developer =
            let
              inherit (final.luaPackages) luacheck;
            in
            final.neovim-debug.overrideAttrs (oa: {
              cmakeFlagsArray =
                oa.cmakeFlagsArray
                ++ [
                  "-DLUACHECK_PRG=${luacheck}/bin/luacheck"
                  "-DENABLE_LTO=OFF"
                ]
                ++ final.lib.optionals final.stdenv.isLinux [
                  # https://github.com/google/sanitizers/wiki/AddressSanitizerFlags
                  # https://clang.llvm.org/docs/AddressSanitizer.html#symbolizing-the-reports
                  "-DENABLE_ASAN_UBSAN=ON"
                ];
              doCheck = final.stdenv.isLinux;
            });
        };
    };
}
