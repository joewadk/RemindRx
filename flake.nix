{
  description = "Computer Vision OCR Project Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (final: prev: {
              python = prev.python3; # Use Python 3
            })
          ];
        };

        pythonPackages = pkgs.python.pkgs;

      in {
        devShells = {
          default = pkgs.mkShell {
            buildInputs = [
              # my-python-env
              pkgs.tesseract
              pkgs.stdenv.cc.cc
              pkgs.stdenv.cc.cc.lib
              pkgs.libGL
              pkgs.glib
              pkgs.glibc
              pkgs.git
              pkgs.nixfmt
            ];

            shellHook = ''
              echo "🐍 Activating Python virtual environment..."

              if [ -z "$CI" ]; then
                if [ ! -d .venv ]; then
                  echo "Creating virtualenv..."
                  python -m venv .venv
                  source .venv/bin/activate
                  pip install --upgrade pip setuptools wheel
                  pip install -r requirements.txt
                else
                  source .venv/bin/activate
                fi
              else
                echo "CI environment detected — skipping local virtualenv setup."
              fi

              echo "✅ Virtual environment ready!"
              # export LD_LIBRARY_PATH=${pkgs.glib.out}/lib:${pkgs.libGL}/lib:${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.glibc}/lib:$LD_LIBRARY_PATH
            '';

          };
        };
      });
}
