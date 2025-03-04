{
  perSystem =
    {
      pkgs,
      config,
      ...
    }:
    {
      devShells = {
        default = pkgs.mkShell {
          name = "neovim-developer-shell";
          inputsFrom = [
            config.packages.neovim-developer
          ];

          dontFixCmake = true;

          packages = config.devShells.minimal.nativeBuildInputs ++ [
            pkgs.clang-tools
          ];
          shellHook = ''
            ${config.packages.neovim-developer.shellHook or ""}
            export ASAN_SYMBOLIZER_PATH=${pkgs.llvm_18}/bin/llvm-symbolizer
            export NVIM_PYTHON_LOG_LEVEL=DEBUG
            export NVIM_LOG_FILE=/tmp/nvim.log

            # ASAN_OPTIONS=detect_leaks=1
            export ASAN_OPTIONS="log_path=./test.log:abort_on_error=1"

            # for treesitter functionaltests
            mkdir -p runtime/parser
            cp -f ${pkgs.vimPlugins.nvim-treesitter.builtGrammars.c}/parser runtime/parser/c.so
          '';

          # Do not fail the hercules-ci because of this shell failing.
          # This often happens due to neovim-developer being broken.
          ignoreFailure = true;
        };

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
            luajit.pkgs.luacheck
            shellcheck
          ];
          shellHook = ''
            export VIMRUNTIME=
          '';
        };
      };
    };
}
