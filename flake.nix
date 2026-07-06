{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      perSystem =
        { pkgs, lib, ... }:
        let
          nativeBuildInputs = [
            pkgs.nil # Nix LSP
            pkgs.haskellPackages.cabal-install # Cabal build tool for Haskell
            pkgs.haskellPackages.haskell-language-server # Haskell LSP

            pkgs.godot_4 # Godot runtime
          ];

          buildInputs = [
            pkgs.haskellPackages.c2hs # c2hs for .chs
          ];
        in
        {
          treefmt = {
            projectRootFile = ".git/config";

            # Nix
            programs.nixfmt.enable = true;

            # Haskell
            programs.ormolu.enable = true;
            programs.cabal-gild.enable = true;

            # GitHub Actions
            programs.actionlint.enable = true;

            # Markdown
            programs.mdformat.enable = true;

            # Shell Scripts
            programs.shfmt.enable = true;
            programs.shellcheck.enable = true;
          };

          devShells.default = pkgs.haskellPackages.shellFor {
            packages = hpkgs: [
              (hpkgs.callCabal2nix "godot-haskell-gdextension" ./. { })
            ];

            inherit nativeBuildInputs buildInputs;
          };
        };
    };
}
