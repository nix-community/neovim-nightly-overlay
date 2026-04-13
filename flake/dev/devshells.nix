{
  perSystem =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      devShellFromNeovim =
        pkg:
        pkg.overrideAttrs (oa: {
          cmakeFlags = config.packages.neovim-developer.cmakeFlags ++ [
            (lib.cmakeFeature "CACHE_PRG" (lib.getExe pkgs.ccache))
          ];

          # avoid neovim-debug's patch to cmake.config/versiondef.h.in to minimize
          # the noisy git diff when patching neovim
          preConfigure = pkgs.neovim-unwrapped.preConfigure;

          nativeBuildInputs = oa.nativeBuildInputs ++ [
            pkgs.stylua
            pkgs.include-what-you-use
            pkgs.clang-tools
          ];
        });

    in
    {
      devShells = {
        default = devShellFromNeovim config.packages.neovim-developer;
        # pkgs.mkShell {
        #   name = "neovim-developer-shell";
        #   inputsFrom =
        #     let
        #       # neovim-developer-ccache = config.packages.neovim-developer.overrideAttrs (oa: {
        #       #   cmakeFlags = oa.cmakeFlags ++ [ (lib.cmakeFeature "CACHE_PRG" (lib.getExe pkgs.ccache)) ];
        #       #
        #       #   # avoid neovim-debug's patch to cmake.config/versiondef.h.in to minimize
        #       #   # the noisy git diff when patching neovim
        #       #   preConfigure = pkgs.neovim-unwrapped.preConfigure;
        #       # });
        #     in
        #     [
        #       # neovim-developer-ccache
        #       config.packages.neovim-developer
        #     ];
        #
        #
        #   packages = config.devShells.minimal.nativeBuildInputs ++ [
        #     pkgs.stylua
        #     pkgs.include-what-you-use
        #     pkgs.clang-tools
        #   ];
        #
        #   shellHook = ''
        #     export NVIM_PYTHON_LOG_LEVEL=DEBUG
        #     export NVIM_LOG_FILE=/tmp/nvim.log
        #
        #     # treesitter parsers needed when running `make functionaltests`
        #     # mkdir -p runtime/parser
        #     # cp -f ${pkgs.vimPlugins.nvim-treesitter.builtGrammars.c}/parser runtime/parser/c.so
        #   '';
        #
        #   # Do not fail the hercules-ci because of this shell failing.
        #   # This often happens due to neovim-developer being broken.
        #   ignoreFailure = true;
        # };

        # Provide a devshell that can be used strictly for developing this flake.
        minimal = pkgs.mkShell.override { inherit (pkgs.llvmPackages_latest) stdenv; } {
          name = "neovim-minimal-shell";
          inputsFrom = [
            config.packages.default
          ];
          packages = with pkgs; [
            (python3.withPackages (ps: [ ps.msgpack ]))
            include-what-you-use
            jq
            lua-language-server
            shellcheck
          ];
          shellHook = ''
            export VIMRUNTIME=
          '';
        };
      };
    };
}
