{
  description = "Nix flake to build tropic01 examples";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/63dacb46bf939521bdc93981b4cbb7ecb58427a0";
    flake-utils.url = "github:numtide/flake-utils/11707dc2f618dd54ca8739b309ec4fc024de578b";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        fs = pkgs.lib.fileset;
        sourceFiles = fs.unions [
          ./libtropic
          ./Linux_SPI
          ./TS1302_devkit
        ];
        src = fs.toSource {
          root = ./.;
          fileset = sourceFiles;
        };

        pname       = "libtropic-linux";
        version     = "1.0.0";

        #java_card_sdk = ./javacard-devkit;

      in {
      devShell = with pkgs; mkShell {
        buildInputs = [
          gcc
          cmake
        ];
        shellHook = ''
          echo "Development environment for libtropic-linux is ready."
        '';
      };

      packages.libtropic-linux = with pkgs; stdenv.mkDerivation {
        name = "libtropic-linux";
        src = ./.;

        buildInputs = [
          gcc
          cmake
        ];

        buildPhase = ''
          mkdir build
          cd build
          cmake -DLT_BUILD_EXAMPLES=1 ..
          make
        '';

        checkPhase = ''
        '';

        installPhase = ''
          mkdir -p $out/bin
          cp -r build/* $out/bin
        '';
      };

      defaultPackage = self.packages.${system}.libtropic-linux;
    });
}
