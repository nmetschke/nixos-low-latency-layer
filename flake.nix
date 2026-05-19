{
  description = "Flake to install low_latency_layer on NixOS";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
      ];
      forEachSupportedSystem =
        f: nixpkgs.lib.genAttrs supportedSystems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      nixosModules = {
        low-latency-layer = (import ./module.nix) self;
        default = self.nixosModules.low-latency-layer;
      };
      packages = forEachSupportedSystem (pkgs: {
        low-latency-layer = pkgs.callPackage ./package.nix { };
        default = self.packages.${pkgs.stdenv.hostPlatform.system}.low-latency-layer;
      });
    };
}
