{
  description = "Neovim flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
    neovim-flake.url = "github:neovim/neovim?dir=contrib";
    neovim-flake.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, neovim-flake, ... }:
    let
      # {
      #   plugin = vim-commentary;
      #   config = ''
      #     '';
      # }
      # {
      #   # TODO generate its runtime/init
      #   plugin = nvim-lspconfig;
      #   # config = ''
      #   # '';
      # }
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        overlays = [ self.overlay ];
        inherit system;
      };
    in
    rec {
      inherit (neovim-flake) defaultPackage apps defaultApp devShell;

      packages = neovim-flake.packages // {
        #
        "${system}".neovim-telescope = pkgs.neovim-telescope;
      };

      overlay = final: prev: rec {
        neovim-unwrapped = neovim-flake.packages.${prev.system}.neovim;
        neovim-nightly = neovim-flake.packages.${prev.system}.neovim;
        neovim-debug = neovim-flake.packages.${prev.system}.neovim-debug;
        neovim-developer = neovim-flake.packages.${prev.system}.neovim-developer;

        # configs
        # lsp-config = 
        # treesitter-config =
        telescope-config = final.neovimUtils.makeNeovimConfig {
          # inherit (cfg)
          #   extraPython3Packages withPython3 extraPythonPackages withPython
          #   withNodeJs withRuby viAlias vimAlias;
          # inherit customRC;
          luaRc = ''
            vim.lsp.set_log_level("info")
          '';
          # configure = cfg.configure // moduleConfigure;

          # plugins = with final.vimPlugins; [ telescope-frecency-nvim ];
        };

        neovim-telescope = final.wrapNeovim neovim-unwrapped 
        # {};
        telescope-config;
                # {
        # plugin = telescope-frecency-nvim;
      # }

      };
    };
}
