self:
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.programs.low-latency-layer;

  wrapperScripts = builtins.attrValues (
    builtins.mapAttrs (
      name: v:
      pkgs.writeShellApplication {
        inherit name;
        runtimeInputs =
          (lib.optional v.mangohud cfg.mangohudPackage) ++ (lib.optional v.gamemode cfg.gamemodePackage);
        text =
          let
            envVars = lib.mergeAttrsList [
              (lib.optionalAttrs v.lowLatencyLayer.enable { LOW_LATENCY_LAYER = 1; })
              (lib.optionalAttrs v.lowLatencyLayer.reflex { LOW_LATENCY_LAYER_REFLEX = 1; })
              (lib.optionalAttrs v.lowLatencyLayer.spoofNvidia { LOW_LATENCY_LAYER_SPOOF_NVIDIA = 1; })
              (lib.optionalAttrs v.lowLatencyLayer.forceDecouple { LOW_LATENCY_LAYER_FORCE_DECOUPLED = 1; })
              (lib.optionalAttrs v.proton.forceNvapi { PROTON_FORCE_NVAPI = 1; })
              (lib.optionalAttrs v.hideAmdGpu { DXVK_CONFIG = "dxgi.hideAmdGpu = True"; })

              v.env
            ];
            envVarsStr = lib.concatStringsSep "\n" (
              lib.mapAttrsToList (name: value: /* sh */ ''export ${name}="${toString value}"'') envVars
            );
          in
          ''
            ${envVarsStr}

            ${lib.concatStringsSep " " (
              [ "exec" ]
              ++ (lib.optional v.mangohud "mangohud")
              ++ (lib.optional v.gamemode "gamemoderun")
              ++ [ ''"$@"'' ]
            )}
          '';
      }
    ) cfg.steamWrappers
  );
in
{
  options.programs.low-latency-layer = {
    enable = lib.mkEnableOption "low-latency-layer";

    package = lib.mkOption {
      description = "The low-latency-layer package to use";
      type = lib.types.package;
      default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };

    mangohudPackage = lib.options.mkPackageOption pkgs "mangohud" {
      extraDescription = "Mangohud package used by wrapper scripts";
    };
    gamemodePackage = lib.options.mkPackageOption pkgs "gamemode" {
      extraDescription = "Gamemode package used by wrapper scripts";
    };

    steamWrappers = lib.mkOption {
      description = ''
        Make wrapper scripts for Steam (or other launchers) that will launch a game with low_latency_layer enabled. The scripts are added to environment.systemPackages.
        To use a script in the Steam launch options: `lowLatency %command%`
      '';
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            lowLatencyLayer = {
              enable = lib.mkOption {
                type = lib.types.bool;
                description = "Enable low_latency_layer";
                default = true;
                example = false;
              };
              reflex = lib.mkOption {
                type = lib.types.bool;
                description = "Make the layer provide Reflex instead of Anti-Lag 2. This option is for better compatibility, as more games support Reflex than Ant-Lag. The same underlying implementation will be used in both cases. Can be disabled if the game supports Anti-Lag 2";
                default = true;
                example = false;
              };
              spoofNvidia = lib.mkOption {
                type = lib.types.bool;
                description = "Report GPU as an NVIDIA GPU to the application. Using `hideAmdGpu` is usually preferable, as this can cause compatibility issues";
                default = false;
                example = true;
              };
              forceDecouple = lib.mkOption {
                type = lib.types.bool;
                description = "Mitigation of a decoupled simulation and render queue. Should only be used for Marvel Rivals";
                default = false;
                example = true;
              };
            };

            hideAmdGpu = lib.mkOption {
              type = lib.types.bool;
              description = "Report AMD GPU as an NVIDIA GPU to the application. Some games may not alow enabling Reflex otherwise";
              default = false;
              example = true;
            };

            proton = {
              forceNvapi = lib.mkOption {
                type = lib.types.bool;
                description = "Force use NVAPI for proton programs";
                default = false;
                example = true;
              };
            };

            mangohud = lib.mkOption {
              type = lib.types.bool;
              description = "Make the wrapper script use mangohud";
              default = false;
              example = true;
            };
            gamemode = lib.mkOption {
              type = lib.types.bool;
              description = "Make the wrapper script use gamemoderun";
              default = false;
              example = true;
            };

            env = lib.mkOption {
              description = "Extra environment variables to set";
              type =
                with lib.types;
                attrsOf (oneOf [
                  str
                  int
                ]);
              default = { };
              example = lib.literalExpression "{ PROTON_ENABLE_WAYLAND = 1; }";
            };
          };
        }
      );
      default = { };
      example = lib.literalExpression ''
        {
          lowLatency = {};
          lowLatencyAmdForce = {
            lowLatencyLayer.reflex = true;
            hideAmdGpu = true;
          };
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.graphics.extraPackages = [ cfg.package ];
    environment.systemPackages = wrapperScripts;
  };
}
