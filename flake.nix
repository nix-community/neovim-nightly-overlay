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
        "${system}".neovim-lsp = pkgs.neovim-lsp;
      };

      overlay = final: prev: rec {
        neovim-unwrapped = neovim-flake.packages.${prev.system}.neovim;
        neovim-nightly = neovim-flake.packages.${prev.system}.neovim;
        neovim-debug = neovim-flake.packages.${prev.system}.neovim-debug;
        neovim-developer = neovim-flake.packages.${prev.system}.neovim-developer;


        config-treesitter = {
          customRc = ''
          '';

          plugins = with final.vimPlugins; [
            { plugin = nvim-treesitter; }
            # { plugin = nvim-lightbulb; }
            # { plugin = telescope-symbols-nvim; }
          ];
        };

        # configs
        config-lsp = {
          customRc = ''
          '';

          plugins = with final.vimPlugins; [
            { plugin = nvim-lspconfig; }
            { plugin = nvim-lightbulb; }
            { plugin = telescope-symbols-nvim; }
          ];
        };

        # treesitter-config =
        # final.neovimUtils.makeNeovimConfig
        config-telescope = {
          customRc = ''
          '';

          plugins = with final.vimPlugins; [
            { plugin = telescope-frecency-nvim; }
            { plugin = telescope-fzf-writer-nvim; }
            { plugin = telescope-symbols-nvim; }
          ];
        };

        neovim-telescope = final.wrapNeovimUnstable neovim-unwrapped config-telescope;
        neovim-lsp = final.wrapNeovimUnstable neovim-unwrapped config-lsp;
        neovim-treesitter = final.wrapNeovimUnstable neovim-unwrapped config-treesitter;

      };
    };
}
