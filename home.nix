{ config, pkgs, ... }:

let
  waybarConfig = ''
    {
      "layer": "top",
      "position": "top",
      "modules-left": ["sway/workspaces", "sway/mode"],
      "modules-center": ["clock"],
      "modules-right": ["tray", "network", "temperature", "pulseaudio", "cpu", "memory", "battery"],

      "tray": {
        "icon-size": 16,
        "spacing": 10
      },

      "network": {
        "interface": "wlo1",
        "format-wifi": " {signalStrength}%",
        "format-ethernet": " {ifname}",
        "format-disconnected": "⚠ Disconnected",
        "tooltip": true
      },

      "temperature": {
        "format": "{}",
        "exec": "/home/ryu/check_temperature.sh",
        "tooltip": true
      },

      "pulseaudio": {
        "format": " {volume}%",
        "tooltip": true
      },

      "cpu": {
        "format": "{usage}%"
      },

      "memory": {
        "format": "{used}MB / {total}MB"
      }
    }
  '';
in

{
  home.username = "ryu";
  home.homeDirectory = "/home/ryu";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    alacritty
    waybar
    swaylock
    git
    vim
    zsh
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    papirus-icon-theme
    catppuccin-gtk
    hyprpaper
    networkmanagerapplet
    wofi
    pulseaudio
  ];

  home.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -al";
      gs = "git status";
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      bind = [
        "$mod, RETURN, exec, alacritty"
        "$mod, Q, killactive,"
        "$mod, F, fullscreen,"
        "$mod SHIFT, E, exit,"
        "$mod, D, exec, wofi --show drun"
      ];
      exec-once = [
        "hyprpaper -w all /home/ryu/Pictures/1340419.png"
        "waybar"
        "nm-applet"
        "/nix/store/rys6134aqazihxi4g5ayc0ky829v7mf0-dbus-1.14.10/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      ];
      monitor = [ ",preferred,auto,1" ];
      env = [ "XCURSOR_SIZE,24" ];
      input = { kb_layout = "ch"; kb_variant = "de"; follow_mouse = 1; };
      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(ff00ffaa)";
        "col.inactive_border" = "rgba(1a1a1aaa)";
      };
    };
  };

  # Prevent double launching Waybar
  programs.waybar.enable = false;

  home.file.".config/waybar/config" = {
    text = waybarConfig;
  };

  home.enableNixpkgsReleaseCheck = false;
}
