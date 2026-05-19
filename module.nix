self:
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.programs.low-latency-layer;
in
{
  options.programs.low-latency-layer = {
    enable = lib.mkEnableOption "low-latency-layer";

    package = lib.mkOption {
      type = lib.types.package;
      # default = pkgs.callPackage ./package.nix { };
      default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
      # default = (import ./. { inherit pkgs; }.low-latency-layer);
      description = "The low-latency-layer package to use.";
    };

    # reflex = lib.mkOption {
    #   type = lib.types.bool;
    #   description = "Sets LOW_LATENCY_LAYER_REFLEX=1 globally";
    #   default = false;
    # };

    # spoofNvidia = lib.mkOption {
    #   type = lib.types.bool;
    #   description = "Sets LOW_LATENCY_LAYER_SPOOF_NVIDIA=1 globally";
    #   default = false;
    # };

    # forceDecouple = lib.mkOption {
    #   type = lib.types.bool;
    #   description = "Sets LOW_LATENCY_LAYER_FORCE_DECOUPLED=1 globally";
    #   default = false;
    # };
  };

  config = lib.mkIf cfg.enable {
    hardware.graphics.extraPackages = [
      cfg.package
    ];

    # environment.sessionVariables = {
    #   PROTON_FORCE_NVAPI = if cfg.enable then "1" else "0";
    #   LOW_LATENCY_LAYER_REFLEX = if cfg.reflex then "1" else "0";
    #   LOW_LATENCY_LAYER_SPOOF_NVIDIA = if cfg.spoofNvidia then "1" else "0";
    #   LOW_LATENCY_LAYER_FORCE_DECOUPLED = if cfg.forceDecouple then "1" else "0";
    # };
  };
}
