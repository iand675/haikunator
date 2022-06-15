{
  inputs = {
    flakeUtils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs";
    pythonOnNix.url = "github:on-nix/python/d8a7fa21b76ac3b8a1a3fedb41e86352769b09ed";
    pythonOnNix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, ... } @ inputs:
    inputs.flakeUtils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        nixpkgs = inputs.nixpkgs.legacyPackages.${system};
        pythonOnNix = inputs.pythonOnNix.lib.${system};

        env = pythonOnNix.python39Env {
          name = "example";
          projects = {
            "textblob" = "0.15.3";
            # You can add more projects here as you need
            # "a" = "1.0";
            # "b" = "2.0";
            # ...
          };
        };
        # `env` has two attributes:
        # - dev: The activation script for the Python on Nix environment
        # - out: The raw contents of the Python site-packages
      in
      {
        devShells = {

          # The activation script can be used as dev-shell
          shell = env.dev;

        };

        packages = {

          # You can also use with Nixpkgs
          example = nixpkgs.stdenv.mkDerivation {
            # Let's use the activation script as build input
            # so the Python environment is loaded
            buildInputs = [ env.dev ];
            virtualEnvironment = env.out;

            builder = builtins.toFile "builder.sh" ''
              source $stdenv/setup

              # textblob will be available here!

              touch $out
            '';
            name = "example";
          };

        };
      }
    );
}

# Usage:
