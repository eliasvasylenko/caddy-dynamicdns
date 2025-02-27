{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self, nixpkgs, nix-vscode-extensions, ... }@inputs:
    let
      forAllSystems = function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
        ] (system: function (rec {
          inherit system;
          pkgs = nixpkgs.legacyPackages.${system};
          extensions = nix-vscode-extensions.extensions.${system};
        }));
    in
    {
      devShells = forAllSystems ({system, pkgs, extensions}: {
        default = pkgs.mkShell {
          buildInputs = [
            (pkgs.vscode-with-extensions.override {
              vscode = pkgs.vscodium;
              vscodeExtensions = [
                extensions.open-vsx.golang.go
                extensions.open-vsx.jnoortheen.nix-ide
              ];
            })
            pkgs.go
          ];
        };
      });
    };
}
