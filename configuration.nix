{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Enable experimental nix features for flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_6_12;
  boot.blacklistedKernelModules = [ "nouveau" ];

  # Hostname & networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Timezone & locale
  time.timeZone = "Africa/Brazzaville";
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "sg";

  # X server & display manager
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  services.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "hyprland-uwsm"; # matches Hyprland session
  programs.hyprland.enable = true;

  # Audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Users
  users.users.ryu = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" ];
    shell = pkgs.zsh;
  };

  # Enable ZSH properly
  programs.zsh.enable = true;

  # NVIDIA setup
  hardware.nvidia = {
  package = pkgs.linuxPackages_6_12.nvidiaPackages.stable;
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

  # Swapfile (12GB)
  swapDevices = [
    { device = "/swapfile"; size = 12288; }
  ];
# ZRAM swap (~2GB)
zramSwap = {
  enable = true;
  memoryPercent = 15; # ~2GB on your 13GB RAM
  algorithm = "zstd"; # fast compression
};


  # Optional programs
  programs.steam.enable = true;

  # System version
  system.stateVersion = "25.05";
}
