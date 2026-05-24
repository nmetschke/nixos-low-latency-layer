# Flake to install [low_latency_layer](https://github.com/Korthos-Software/low_latency_layer) on NixOS

## Installation
Add this repo as a flake input and use the module.
```nix
{
  inputs.low-latency-layer = {
    url = "github:nmetschke/nixos-low-latency-layer?shallow=1";
    # inputs.nixpkgs.follows = "nixpkgs"; # optional, requires unstable
  };

  
  outputs = { nixpkgs, low-latency-layer, ... }: {
    nixosConfigurations.<system> = nixpkgs.lib.nixosSystem {
      modules = [
        low-latency-layer.nixosModules.low-latency-layer
      ];
    };
  };
}
	
``` 

# Usage
The module provides
```nix
	programs.low-latency-layer.enable = true;
```
for easy usage (it just adds the package to `hardware.graphics.extraPackages`).

Afterwards, refer to the [low_latency_layer Documentation](https://github.com/Korthos-Software/low_latency_layer#usage-and-configuration) for the appropriate environment variables to set.

#### Steam launch options example:
``
  LOW_LATENCY_LAYER=1 LOW_LATENCY_LAYER_REFLEX=1 DXVK_CONFIG="dxgi.hideAmdGpu = True" %command%
``
