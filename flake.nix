{
  description = "Hugo Docsy development environment";

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
            hugo                    # Hugo extended (required for Docsy)
            nodejs_20              # Node.js for PostCSS and dependencies
            git                     # Git for submodule management
            go                      # Go for Hugo modules
            dart-sass              # Dart Sass for SCSS compilation
            # nodePackages.postcss-cli
            nodePackages.autoprefixer
          ];

          shellHook = ''
            echo "Hugo Docsy Development Environment Ready"
            echo "Hugo version: $(hugo version)"
            echo "Node.js version: $(node --version)"
            echo "Go version: $(go version)"
          '';
        };
      }
    );
}
