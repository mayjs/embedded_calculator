# This file is pretty general, and you can adapt it in your project replacing
# only `name` and `description` below.

{
  description = "A universal calculator and conversion tool targeted at low-level / embedded software development";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, ... }:
    flake-utils.lib.eachDefaultSystem 
      (system:
        let
          overlays = [ rust-overlay.overlays.default ];
          pkgs = import nixpkgs { inherit system overlays; };
          rust = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
          build_deps = [rust pkgs.wasm-bindgen-cli pkgs.cargo pkgs.trunk];
          libPath = with pkgs; lib.makeLibraryPath [
            libGL
            libxkbcommon
            wayland
            xorg.libX11
            xorg.libXcursor
            xorg.libXi
            xorg.libXrandr
          ];
        in
        {
          devShell = pkgs.mkShell {
            packages = build_deps ++ [ pkgs.rustfmt pkgs.rust-analyzer ];
            LD_LIBRARY_PATH = libPath;
          };
        }
      );
}

