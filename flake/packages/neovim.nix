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
    lua5_1 = pkgs.luajit;
    inherit tree-sitter;

    treesitter-parsers =
      let
        grammars = lib.filterAttrs (name: _: lib.hasPrefix "treesitter_" name) deps;
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

  preConfigure = ''
    ${oa.preConfigure}
    substituteInPlace cmake.config/versiondef.h.in \
      --replace-fail '@NVIM_VERSION_PRERELEASE@' '-nightly+${neovim-src.shortRev or "dirty"}'
  '';
})
