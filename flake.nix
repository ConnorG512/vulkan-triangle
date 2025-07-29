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
      ];
    };
  };
}
