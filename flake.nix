{
  description = "Nix flake for Antigravity CLI - Google's agentic coding assistant in your terminal";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      overlay = final: prev: {
        antigravity-cli = final.callPackage ./package.nix { };
      };
    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
          config.allowUnfreePredicate = pkg: (nixpkgs.lib.getName pkg) == "antigravity-cli";
        };
      in
      {
        packages = {
          default = pkgs.antigravity-cli;
          antigravity-cli = pkgs.antigravity-cli;
        };

        apps = {
          default = {
            type = "app";
            program = "${pkgs.antigravity-cli}/bin/agy";
          };
          antigravity-cli = {
            type = "app";
            program = "${pkgs.antigravity-cli}/bin/agy";
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nixpkgs-fmt
            jq
          ];
        };
      }) // {
        overlays.default = overlay;
      };
}
