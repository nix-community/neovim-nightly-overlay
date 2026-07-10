{
  neovim-src,
  lib,
  pkgs,
  neovim-dependencies,
  tree-sitter,
  ...
}:
let
  src = neovim-src;
  deps = neovim-dependencies;
  treesitterDeps = lib.filterAttrs (name: _: lib.hasPrefix "treesitter_" name) deps;
  wasmParserDeps = lib.filterAttrs (name: _: lib.hasSuffix "_wasm" name) treesitterDeps;
  hasWasmCmakeFlag = cmakeFlags: lib.any (lib.hasPrefix "-DENABLE_WASMTIME") cmakeFlags;

  # The following overrides will only take effect for linux hosts
  linuxOnlyOverrides = lib.optionalAttrs pkgs.stdenv.isLinux {
    gettext = pkgs.gettext.overrideAttrs {
      # FIXME: nixpkgs' gettext is now at version 0.22.5 whereas neovim's is pinned at 0.20.5
      # Overriding the source leads to a build error of gettext.
      # Neovim seems to build fine with nixpkgs' gettext, so we use that in the meantime.
      # src = deps.gettext;
    };
  };

  overrides = {
    libuv = pkgs.libuv.overrideAttrs {
      # FIXME: overriding libuv casues high CPU usage on darwin
      # https://github.com/nix-community/neovim-nightly-overlay/issues/538
      # src = deps.libuv;
    };
    inherit tree-sitter;

    treesitter-parsers =
      # `treesitter_*` deps are grammar sources. `treesitter_*_wasm` deps are
      # prebuilt parser binaries and get installed separately when supported.
      lib.mapAttrs' (
        name: value: lib.nameValuePair (lib.removePrefix "treesitter_" name) { src = value; }
      ) (lib.filterAttrs (name: _: !lib.hasSuffix "_wasm" name) treesitterDeps);
  }
  // linuxOnlyOverrides;
in
(pkgs.neovim-unwrapped.override overrides).overrideAttrs (oa: {
  version = "${neovim-src.shortRev or "dirty"}";
  inherit src;

  # Workaround: nixpkgs applies CVE-2026-11487.patch, but the fix is already
  # part of nightly (neovim/neovim@f83e0dca), so it fails as already applied.
  # Remove once nixpkgs drops the patch (NixOS/nixpkgs#530655).
  patches = builtins.filter (patch: !lib.hasInfix "CVE-2026-11487" (toString patch)) (
    oa.patches or [ ]
  );

  postPatch =
    # NOTE: Upstream nixpkgs needed to loosen requirements on stable release of neovim.
    # Nightly already has support for loosened requirements.
    lib.replaceStrings
      [
        ''
          substituteInPlace src/nvim/CMakeLists.txt \
            --replace-fail \
              'find_package(Wasmtime 36.0.6 EXACT REQUIRED)' \
              'find_package(Wasmtime REQUIRED)'
        ''
      ]
      [
        ""
      ]
      (oa.postPatch or "");

  # Setting XDG_RUNTIME_DIR expliclity to TMPDIR prevents stdpath('run') from
  # falling back to '$TMPDIR/nvim.<user>/<rand>' which (adding cmake 'Xtest_tmpdir_<suite')
  # makes functionaltest fail due to socket path being too long (104 bytes on darwin)
  preCheck = (oa.preCheck or "") + ''
    export XDG_RUNTIME_DIR="$(mktemp -d)"
  '';

  preConfigure = ''
    ${oa.preConfigure}
  ''
  + lib.optionalString (hasWasmCmakeFlag oa.cmakeFlags) (
    lib.concatStrings (
      lib.mapAttrsToList (name: value: ''
        install -Dm444 ${value} $out/lib/nvim/parser/${lib.removeSuffix "_wasm" (lib.removePrefix "treesitter_" name)}.wasm
      '') wasmParserDeps
    )
  )
  + ''
    substituteInPlace cmake.config/versiondef.h.in \
      --replace-fail '@NVIM_VERSION_PRERELEASE@' '-nightly+${neovim-src.shortRev or "dirty"}'
  '';

  # Workaround: neovim renamed nvim.desktop to org.neovim.nvim.desktop,
  # but the nixpkgs wrapper still references the old name.
  # Create a compatibility copy until nixpkgs is updated.
  # https://github.com/nix-community/neovim-nightly-overlay/issues/1244
  postInstall =
    (oa.postInstall or "")
    # Neovim's WASM tests compare native and WASM lua parsers, so remove
    # duplicate native runtime parsers only after checks run.
    + lib.optionalString (hasWasmCmakeFlag oa.cmakeFlags) (
      lib.concatStrings (
        lib.mapAttrsToList (name: _: ''
          rm -f $out/lib/nvim/parser/${lib.removeSuffix "_wasm" (lib.removePrefix "treesitter_" name)}.so
        '') wasmParserDeps
      )
    )
    + lib.optionalString pkgs.stdenv.hostPlatform.isLinux ''
      if [ ! -e $out/share/applications/nvim.desktop ]; then
        cp $out/share/applications/org.neovim.nvim.desktop $out/share/applications/nvim.desktop 2>/dev/null || true
      fi
    '';
})
