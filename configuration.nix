{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

#  boot.kernelPackages = pkgs.linuxPackages_6_1;
  boot.blacklistedKernelModules = [ "nouveau" ];

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Africa/Brazzaville";

  i18n.defaultLocale = "en_GB.UTF-8";

  console.keyMap = "sg";  # Swiss German for TTY

  # Wayland display manager
  services.xserver.enable = false;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  services.desktopManager.plasma6.enable = false;

  # Audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # User
  users.users.ryu = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  programs.steam.enable = true;

  # NVIDIA configuration
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
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

  # ✅ Enable Hyprland as a system session
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  system.stateVersion = "25.05";
}
