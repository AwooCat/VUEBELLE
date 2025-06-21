{
  description = "Hyprland Gaming NixOS with Home Manager and NVIDIA";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      hostname = "nixos";
      username = "ryu";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system pkgs;

        modules = [
          ./configuration.nix

          ({ config, pkgs, ... }: let
            nvidiaPackages = pkgs.linuxPackages_6_1.nvidiaPackages;
          in {
            boot.kernelPackages = pkgs.linuxPackages_6_1;
            boot.blacklistedKernelModules = [ "nouveau" ];

            services.xserver.videoDrivers = [ "nvidia" ];

            hardware.nvidia = {
              package = nvidiaPackages.stable;
              modesetting.enable = true;
              nvidiaSettings = true;
              nvidiaPersistenced = true;
              open = false;
              prime = {
                offload.enable = true;
                amdgpuBusId = "PCI:5:0:0";
                nvidiaBusId = "PCI:1:0:0";
              };
            };

            environment.variables = {
              __GLX_VENDOR_LIBRARY_NAME = "nvidia";
              GBM_BACKEND = "nvidia-drm";
              LIBVA_DRIVER_NAME = "nvidia";
            };

            environment.systemPackages = with pkgs; [
              hyprland
              hyprpaper
              waybar
              wofi
              librewolf
              firefox
              steam
              lutris
              heroic
              fastfetch
              kdePackages.okular
              nvidiaPackages.stable
            ];
          })
        ];
      };

      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
      };
    };
}
