{ config, pkgs, ... }:

let
  waybarConfig = ''
    {
      "layer": "top",
      "position": "top",
      "modules-left": ["sway/workspaces", "sway/mode"],
      "modules-center": ["clock"],
      "modules-right": ["tray", "network", "cpu", "memory", "temperature", "battery"],

      "tray": {
        "icon-size": 16,
        "spacing": 10
      },

      "network": {
        "interface": "wlo1",
        "format-wifi": " {essid} ({signalStrength}%)",
        "format-ethernet": " {ifname}",
        "format-disconnected": "⚠ Disconnected",
        "tooltip": true
      },

      "cpu": {
        "format": "{usage}%"
      },

      "memory": {
        "format": "{used}MB / {total}MB"
      },

      "temperature": {
        "format": "{temperature}°C"
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
      ];

      exec-once = [
        "hyprpaper"
        "waybar"
        "nm-applet"
      ];

      monitor = [ ",preferred,auto,1" ];

      env = [
        "XCURSOR_SIZE,24"
      ];

      input = {
        kb_layout = "ch";
        kb_variant = "de";
        follow_mouse = 1;
      };

      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(ff00ffaa)";
        "col.inactive_border" = "rgba(1a1a1aaa)";
      };
    };
  };

  programs.waybar = {
    enable = true;
  };

  home.file.".config/waybar/config" = {
    text = waybarConfig;
  };

  home.enableNixpkgsReleaseCheck = false;
}
