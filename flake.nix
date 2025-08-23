{
  description = "Pingtower development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            fish
            gnumake
          ];

          shellHook = ''
            echo "Welcome to Pingtower development environment!"
            echo "Available tools:"
            echo "  - fish: ${pkgs.fish.version}"
            echo "  - gnumake: ${pkgs.gnumake.version}"
            echo ""
            exec ${pkgs.fish}/bin/fish
          '';
        };
      });
}
