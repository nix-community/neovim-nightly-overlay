{
  neovim-src,
  lib,
  pkgs,
  ...
}: let
  src = neovim-src;

  deps = lib.pipe "${src}/cmake.deps/deps.txt" [
    builtins.readFile
    (lib.splitString "\n")
    (map (builtins.match "([A-Z0-9_]+)_(URL|SHA256)[[:space:]]+([^[:space:]]+)[[:space:]]*"))
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
      lua = pkgs.luajit;
      tree-sitter =
        (pkgs.tree-sitter.override {
          rustPlatform =
            pkgs.rustPlatform
            // {
              buildRustPackage = args:
                pkgs.rustPlatform.buildRustPackage (args
                  // {
                    version = "bundled";
                    src = deps.treesitter;
                    cargoHash = "sha256-umNoJn5fctYk3J2ekYjJx1fCwfAMspEHjmYUvw6Qb0Y=";
                  });
            };
        })
        .overrideAttrs (oa: {
          postPatch = ''
            ${oa.postPatch}
            sed -e 's/playground::serve(.*$/println!("ERROR: web-ui is not available in this nixpkgs build; enable the webUISupport"); std::process::exit(1);/' \
                -i cli/src/main.rs
          '';
        });

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
      sed -i cmake.config/versiondef.h.in -e 's/@NVIM_VERSION_PRERELEASE@/-nightly+${neovim-src.shortRev or "dirty"}/'
    '';

    buildInputs = let
      nvim-lpeg-dylib = luapkgs:
        if pkgs.stdenv.hostPlatform.isDarwin
        then
          (luapkgs.lpeg.overrideAttrs (oa: {
            preConfigure = ''
              # neovim wants clang .dylib
              sed -i makefile -e "s/CC = gcc/CC = clang/"
              sed -i makefile -e "s/-bundle/-dynamiclib/"
              sed -i makefile -e "s/lpeg.so/lpeg.dylib/"
              sed -i makefile -e '/^linux:$/ {N; d;}'
              cat makefile
            '';
            preBuild = ''
              # there seems to be implicit calls to Makefile from luarocks, we need to
              # add a stage to build our dylib
              make macosx
              mkdir -p $out/lib/lua/5.1
              mv lpeg.dylib $out/lib/lua/5.1/lpeg.dylib
            '';
            postInstall = ''
              rm -f $out/lib/lua/5.1/lpeg.so
            '';
            nativeBuildInputs =
              oa.nativeBuildInputs
              ++ (
                lib.optional pkgs.stdenv.hostPlatform.isDarwin pkgs.fixDarwinDylibNames
              );
          }))
        else luapkgs.lpeg;
      requiredLuaPkgs = ps: (
        with ps; [
          (nvim-lpeg-dylib ps)
          luabitop
          mpack
        ]
      );
    in
      with pkgs;
        [
          # TODO: remove once upstream nixpkgs updates the base drv
          (utf8proc.overrideAttrs (_: {
            src = deps.utf8proc;
          }))
        ]
        ++ builtins.filter (input: builtins.match "luajit-.*-env" input.name == null) oa.buildInputs
        ++ [
          (pkgs.luajit.withPackages requiredLuaPkgs)
        ];
  })
