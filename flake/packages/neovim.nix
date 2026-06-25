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
      let
        # Exclude prebuilt `treesitter_*_wasm` parsers (neovim/neovim#40304):
        # they're .wasm binaries, not grammar sources, so buildGrammar can't
        # unpack them. Unused here anyway, as nixpkgs builds without wasmtime.
        grammars = lib.filterAttrs (
          name: _: lib.hasPrefix "treesitter_" name && !lib.hasSuffix "_wasm" name
        ) deps;
      in
      lib.mapAttrs' (
        name: value: lib.nameValuePair (lib.removePrefix "treesitter_" name) { src = value; }
      ) grammars;
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

  preConfigure = ''
    ${oa.preConfigure}
    substituteInPlace cmake.config/versiondef.h.in \
      --replace-fail '@NVIM_VERSION_PRERELEASE@' '-nightly+${neovim-src.shortRev or "dirty"}'
  '';

  # Workaround: neovim renamed nvim.desktop to org.neovim.nvim.desktop,
  # but the nixpkgs wrapper still references the old name.
  # Create a compatibility copy until nixpkgs is updated.
  # https://github.com/nix-community/neovim-nightly-overlay/issues/1244
  postInstall =
    (oa.postInstall or "")
    + lib.optionalString pkgs.stdenv.hostPlatform.isLinux ''
      if [ ! -e $out/share/applications/nvim.desktop ]; then
        cp $out/share/applications/org.neovim.nvim.desktop $out/share/applications/nvim.desktop 2>/dev/null || true
      fi
    '';
})
