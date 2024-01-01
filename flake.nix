# flake.nix

{
  description = "LLVM Linker ang example project description";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    devShell.x86_64-linux =
      let
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
      in pkgs.mkShell {
        buildInputs = [
          pkgs.clang
          pkgs.curl
          pkgs.llvmPackages_17.libllvm
          pkgs.binaryen
          pkgs.wasmtime
          pkgs.emscripten
          pkgs.go
        ];

        shellHook = ''
          echo "Using Python version: $(${pkgs.python38} --version)"

	  # Create the obj directory if it doesn't exist
	  mkdir -p obj

          # Compile main.c to LLVM IR
          clang -S -emit-llvm -I./include src/main.c -o obj/main.ll

          # Compile functions.c to LLVM IR
          clang -S -emit-llvm -I./include src/functions.c -o obj/functions.ll

          # Compile functions.c to an object file
          clang -c -I./include src/functions.c -o obj/functions.o

	  # Create the lib directory if it doesn't exist
	  mkdir -p lib

          # Create a library from the object file
          ar rcs lib/libfunctions.a obj/functions.o

	  # Compile main.ll with libfunctions.a to create my_program
	  clang obj/main.ll lib/libfunctions.a -o my_program


          echo "Entering the development environment!"
        '';
      };

    devShells = rec {
      default = self.devShell.x86_64-linux;
    };
  };
}

