{
  description = "Hyprland Gaming NixOS with Home Manager";

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
        inherit system;
        pkgs = pkgs;

        modules = [
          ./configuration.nix

          ({ pkgs, lib, ... }: {
            programs.hyprland = {
              enable = true;
              withUWSM = true;
              xwayland.enable = true;
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
              lm_sensors
            ];

            # Load CPU temperature kernel modules (adjust if necessary)
            boot.kernelModules = lib.mkForce [ "k10temp" "coretemp" ];
          })
        ];
      };

      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
      };
    };
}
