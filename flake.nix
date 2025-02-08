{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    systems = ["x86_64-linux"];
    forEachSystem = nixpkgs.lib.genAttrs systems;
    pkgsForEach = nixpkgs.legacyPackages;
    nix.config.substituters = [
      "cache.nixos.org"
      "cache.komunix.org"
    ];
  in {
    packages = forEachSystem (system: {
      default = self.packages.${system}.nysh;
      nysh = pkgsForEach.${system}.callPackage ./nix/package.nix {
        quickshell = inputs.quickshell.packages.${system}.default;
      };
    });

    devShells = forEachSystem (system: {
      default = pkgsForEach.${system}.callPackage ./nix/shell.nix {
        quickshell = inputs.quickshell.packages.${system}.default;
      };
    });
  };
}
