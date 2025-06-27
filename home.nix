{ config, pkgs, lib, ... }:

let
  waybarConfig = ''
  {
    "layer": "top",
    "position": "top",
    "modules-left": ["cpu", "memory", "sway/workspaces", "sway/mode"],
    "modules-center": ["clock"],
    "modules-right": ["tray", "custom/wifi", "temperature", "custom/volume", "battery"],

    "tray": {
      "icon-size": 16,
      "spacing": 10
    },

    "custom/wifi": {
      "exec": "~/.config/waybar/scripts/wifi-connect.sh",
      "format": "{}",
      "interval": 10,
      "on-click": "~/.config/waybar/scripts/wifi-connect.sh"
    },

    "custom/volume": {
      "exec": "~/.config/waybar/scripts/volume.sh",
      "interval": 3,
      "return-type": "json",
      "on-scroll-up": "pamixer -i 5",
      "on-scroll-down": "pamixer -d 5",
      "on-click": "pamixer -t",
      "tooltip": true
    },

    "temperature": {
      "exec": "/home/ryu/.config/waybar/check_temperature.sh",
      "interval": 10,
      "tooltip": true,
      "format": " {}°C"
    },

    "cpu": {
      "format": " {usage}%",
      "tooltip": true
    },

    "memory": {
      "format": "󰍛 {used:0.1f}G / {total:0.1f}G",
      "tooltip": true
    },

    "battery": {
      "format": "🔋 {capacity}%",
      "format-charging": "⚡ {capacity}%",
      "tooltip": true
    },

    "clock": {
      "format": "{:%H:%M}"
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
    alacritty waybar swaylock git vim zsh
    jetbrains-mono nerd-fonts.jetbrains-mono
    papirus-icon-theme catppuccin-gtk hyprpaper
    networkmanagerapplet wofi pulseaudio grim slurp gimp pamixer
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

  programs.waybar.enable = true;

  home.file.".config/waybar/config".text = waybarConfig;

  # Waybar style.css (closed properly)
  home.file.".config/waybar/style.css".text = ''
* {
  font-family: "JetBrainsMono Nerd Font Mono";
  font-size: 13px;
}

#waybar {
  background: rgba(26, 26, 26, 0.95);
  color: #ffffff;
  border-bottom: 1px solid #444;
  padding: 0 10px;
}

#battery, #memory, #cpu, #temperature, #pulseaudio, #network, #clock, #tray, #custom-wifi {
  margin: 0 8px;
}

#battery {
  color: #43fbff;
}

#battery.warning {
  color: #FFD300;
}

#battery.critical {
  color: #FF06B5;
}

#custom-wifi {
  color: #43fbff;
}

#custom-wifi.disconnected {
  color: #FF0000;
}

#custom-volume {
  color: #43fbff;
}

#clock {
  color: #43fbff;
}

#custom-volume.low {
  color: #43fbff;
}

#custom-volume.medium {
  color: #FFD300;
}

#custom-volume.high {
  color: #FF06B5;
}
'';

  # Waybar scripts (make sure executable and source paths are correct)
  home.file.".config/waybar/scripts/volume.sh" = {
    source = ./scripts/volume.sh;
    executable = true;
  };

  home.file.".config/waybar/scripts/network-status.sh" = {
    source = ./scripts/network-status.sh;
    executable = true;
  };

  home.file.".config/waybar/scripts/wifi-connect.sh" = {
    source = ./scripts/wifi-connect.sh;
    executable = true;
  };

  # Random wallpaper changer script
  home.file.".config/hypr/random-wallpaper.sh" = {
    text = ''
      #!/usr/bin/env bash

      WALLPAPER_DIR="$HOME/Pictures/walls"
      MONITOR="eDP-1"

      WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

      hyprctl hyprpaper preload "$WALLPAPER"
      hyprctl hyprpaper wallpaper "$MONITOR,$WALLPAPER"
    '';
    executable = true;
  };

  # Hyprpaper daemon service
  systemd.user.services.hyprpaper = {
    Unit = {
      Description = "Hyprpaper daemon";
      After = [ "network.target" ];
    };
    Service = {
      ExecStart = "${pkgs.hyprpaper}/bin/hyprpaper";
      Restart = "always";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Wallpaper changer service
  systemd.user.services.hyprpaper-random = {
    Unit = {
      Description = "Set random wallpaper using Hyprpaper";
    };
    Service = {
      ExecStart = "${config.home.homeDirectory}/.config/hypr/random-wallpaper.sh";
      Type = "oneshot";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Timer for wallpaper changer every 10 minutes
  systemd.user.timers.hyprpaper-random = {
    Unit = {
      Description = "Run wallpaper change every 10 minutes";
    };
    Timer = {
      OnBootSec = "1min";
      OnUnitActiveSec = "10min";
      Unit = "hyprpaper-random.service";
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };

  # Make sure scripts are executable
  home.activation.makeScriptsExecutable = lib.hm.dag.entryAfter ["writeBoundary"] ''
    chmod +x $HOME/scripts/network-*.sh
    chmod +x $HOME/.config/waybar/scripts/*.sh
  '';

  # Hyprland window manager configuration
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      bind = [
        "$mod, RETURN, exec, alacritty"
        "$mod, Q, killactive"
        "$mod, F, fullscreen"
        "$mod SHIFT, E, exit"
        "$mod, D, exec, wofi --show drun"
        "$mod, S, exec, bash -c 'TMP_SCREENSHOT=/home/ryu/Pictures/screenshot-$(date +%s).png; grim -g \"$(slurp)\" \"$TMP_SCREENSHOT\" && gimp \"$TMP_SCREENSHOT\"'"
        "$mod, L, exec, librewolf"
        "$mod, M, exec, steam"
      ];
      exec-once = [
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE"
        "waybar"
        "hyprpaper"
      ];
      monitor = [ ",preferred,auto,1" ];
      env = [ "XCURSOR_SIZE,24" ];
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

  home.enableNixpkgsReleaseCheck = false;
}
