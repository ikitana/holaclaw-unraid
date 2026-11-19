{
  description = "Unraid template for HolaClaw";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          libxml2          # xmllint: the template must be well-formed XML
          docker-client    # host tests of the template, against the system's daemon
          gh               # .claude/skills: issues and pull requests
        ];
      };

      formatter = pkgs.nixfmt-rfc-style;
    });
}
