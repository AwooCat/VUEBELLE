{
  description = "Hyprland Gaming NixOS with Home Manager (VueBelle)";

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
      config = { allowUnfree = true; };
    };
  in {
    nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
      inherit system pkgs;

      modules = [
        ./configuration.nix

        ({ pkgs, lib, ... }: {
          programs.hyprland.enable = true;
          programs.hyprland.withUWSM = true;
          programs.hyprland.xwayland.enable = true;

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
            lm_sensors
            wine
            winetricks
            signal-desktop
            lolcat
            pcmanfm
            gvfs
            udisks2
            usbimager
          ];

          boot.kernelModules = lib.mkForce [ "k10temp" "coretemp" ];

          systemd.services.zram-setup = {
            description = "ZRAM swap setup";
            after = [ "systemd-modules-load.service" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
              Environment = "PATH=/run/current-system/sw/bin:/run/current-system/sw/sbin:/usr/bin:/bin";
              ExecStart = ''
                /run/current-system/sw/bin/modprobe zram num_devices=1
                echo $((2*1024*1024*1024)) > /sys/block/zram0/disksize
                /run/current-system/sw/bin/mkswap /dev/zram0
                /run/current-system/sw/bin/swapon /dev/zram0
              '';
            };
          };

          swapDevices = [
            { device = "/swapfile"; size = 12288; }
          ];
        })
      ];
    };

    homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      modules = [
        ./home.nix

        {
          home.file."scripts/network-connect.sh".source = ./scripts/network-connect.sh;
        }
      ];
    };
  };
}
