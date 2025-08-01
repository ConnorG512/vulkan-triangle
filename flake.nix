{
  description = "Vulkan triangle flake.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in 
  {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        zig
        vulkan-headers
        vulkan-validation-layers
        vulkan-memory-allocator
        vulkan-loader
        glfw
        mesa

        libxkbcommon

        xorg.libX11
        xorg.libXcursor
        xorg.libXrandr
        xorg.libXi
        xorg.libXinerama
        xorg.libXext

        lldb_21
      ];
      
      shellHook = ''
        echo "Entering vulkan triangle dev shell..."
        export LD_LIBRARY_PATH="${
          pkgs.lib.makeLibraryPath [
            pkgs.glfw 
            pkgs.vulkan-validation-layers
            pkgs.vulkan-headers
            pkgs.mesa
            
            pkgs.xorg.libX11
            pkgs.xorg.libXcursor
            pkgs.xorg.libXrandr
            pkgs.xorg.libXi
            pkgs.xorg.libXinerama
            pkgs.xorg.libXext
            pkgs.libxkbcommon
          ]
        }:$LD_LIBRARY_PATH"
      '';
    };
  };
}
