{
  description = "typstar nix flake for development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem = {system, ...}: let
        pkgs = import nixpkgs {inherit system;};
        typstar = pkgs.vimUtils.buildVimPlugin {
          name = "typstar";
          src = self;
          buildInputs = [
            pkgs.vimPlugins.luasnip
            pkgs.vimPlugins.nvim-treesitter-parsers.typst
          ];
        };
      in {
        packages = {
          default = typstar;
          nvim = let
            config = pkgs.neovimUtils.makeNeovimConfig {
              customRC = ''
                lua << EOF
                print("Welcome to Typstar! This is just a demo.")

                require('nvim-treesitter.configs').setup {
                  highlight = { enable = true },
                }

                require('luasnip').config.set_config({
                     enable_autosnippets = true,
                })

                require('typstar').setup()
                EOF
              '';
              plugins = [
                typstar
                pkgs.vimPlugins.luasnip
                pkgs.vimPlugins.nvim-treesitter
                pkgs.vimPlugins.nvim-treesitter-parsers.typst
              ];
            };
          in
            pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped config;
        };
      };
    };
}
