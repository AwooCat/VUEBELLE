{ config, pkgs, lib, ... }:
let
  waybarConfig = ''
{
  "layer": "top",
  "position": "top",

  "modules-left": [
    "custom/cpu",
    "custom/space",
    "custom/memory",
    "custom/space",
    "sway/workspaces",
    "custom/space",
    "sway/mode"
  ],

  "modules-center": ["clock"],

  "modules-right": [
    "tray",
    "custom/space",
    "custom/wifi",
    "custom/space",
    "custom/temperature",
    "custom/space",
    "custom/volume",
    "custom/space",
    "battery"
  ],

  "custom/space": {
    "format": "   ",
    "tooltip": false
  },

  "tray": {
    "icon-size": 16,
    "spacing": 10
  },

  "clock": {
    "format": "{:%H:%M}"
  },

  "custom/wifi": {
    "exec": "~/.config/waybar/scripts/geko-wifi.sh",
    "interval": 10,
    "format": "{}",
    "on-click": "~/.config/waybar/scripts/wifi-connect.sh",
    "return-type": "json",
    "tooltip": true
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

  "custom/temperature": {
    "exec": "~/.config/waybar/scripts/ryzen-geko.sh",
    "interval": 10,
    "format": "🧮 {text}",
    "return-type": "json",
    "tooltip": true
  },

  "custom/cpu": {
    "exec": "~/.config/waybar/scripts/cpu-usage.sh",
    "interval": 5,
    "return-type": "json",
    "tooltip": true,
    "on-click": "alacritty -e btop"
  },

  "custom/memory": {
    "exec": "~/.config/waybar/scripts/memory-usage.sh",
    "interval": 10,
    "return-type": "json",
    "tooltip": true,
    "on-click": "alacritty -e htop"
  },

  "battery": {
    "format": "🔋 {capacity}%",
    "low": 40,
    "critical": 0
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
     wofi pulseaudio grim slurp gimp pamixer btop htop blueman glpaper
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
  font-family: "JetBrainsMono Nerd Font Mono", monospace;
  font-size: 13px;
}

/* For modules with emoji/icons */
#custom-wifi, #battery, #cpu, #custom-volume {
  font-family: "JetBrainsMono Nerd Font Mono";
}

#waybar {
    background-image: url("background.png");
    background-size: cover;
    background-repeat: no-repeat;
    background-position: center;
}

#waybar > * {
    /* Removed position and z-index */
}





.modules-left > *:not(:last-child),
.modules-center > *:not(:last-child),
.modules-right > *:not(:last-child) {
  margin-right: 12px;
}

#battery,
#memory,
#cpu,
#temperature,
#pulseaudio,
#network,
#clock,
#tray,
#custom-wifi,
#custom-volume,
#custom-cpu,
#custom-memory {
  margin: 0 8px;
}


#custom-temperature.warning {
  color: #FFD300;
}

#custom-temperature.critical {
  color: #FF06B5;
}

#custom-temperature {
  color: #43fbff;
}
#custom-cpu.low {
  color: #43fbff;
}

#custom-cpu.medium {
  color: #FFD300;
}

#custom-cpu.high {
  color: #FF06B5;
}
#battery {
  color: #ff06b5; /* Pink for 70-100% */
}

#battery.low {
  color: #FFD300; /* Yellow for 40-69% */
}

#battery.critical {
  color: #43fbff; /* Cyan for 0-39% */
}

#custom-wifi {
  color: #43fbff;
}

#custom-wifi.warning {
  color: #FFD300;
}

#custom-wifi.critical {
  color: #FF06B5;
}


#custom-wifi.disconnected {
  color: #FF0000;
}

#custom-volume {
  color: #43fbff;
}
#custom-memory.low {
  color: #43fbff;
}

#custom-memory.medium {
  color: #FFD300;
}

#custom-memory.high {
  color: #FF06B5;
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
/* Bigger RAM, WiFi, CPU, Volume, Battery, Temperature symbols */
#custom-memory,
#custom-wifi,
#custom-cpu,
#custom-volume,
#battery,
#custom-temperature {
  font-size: 16px;
}
'';

  # Waybar scripts (make sure executable and source paths are correct)
  # Waybar scripts
  home.file.".config/waybar/scripts/volume.sh" = {
    source = ./scripts/volume.sh;
    executable = true;
  };

  home.file.".config/waybar/scripts/wifi-connect.sh" = {
    source = ./scripts/wifi-connect.sh;
    executable = true;
  };

  home.file.".config/waybar/scripts/geko-wifi.sh" = {
    source = ./scripts/geko-wifi.sh;
    executable = true;
  };

  home.file.".config/waybar/scripts/ryzen-geko.sh" = {
    source = ./scripts/ryzen-geko.sh;
    executable = true;
  };

  home.file.".config/waybar/scripts/cpu-usage.sh" = {
    source = ./scripts/cpu-usage.sh;
    executable = true;
  };

  home.file.".config/waybar/scripts/memory-usage.sh" = {
    source = ./scripts/memory-usage.sh;
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
  
  # GLPaper shader wallpaper service
systemd.user.services.glpaper = {
  Unit = {
    Description = "GLPaper shader wallpaper";
    After = [ "network.target" ];
  };
  Service = {
    Environment = "WAYLAND_DISPLAY=wayland-0";
    ExecStart = "${pkgs.glpaper}/bin/glpaper --shader /home/ryu/Shaders/working_blackhole.frag --output eDP-1";
    Restart = "always";
    RestartSec = 5;
  };
  Install = {
    WantedBy = [ "default.target" ];
  };
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
        "$mod, SPACE, togglefloating"
       ];

bindm = [
  "$mod, mouse:272, movewindow"
  "$mod, mouse:273, resizewindow"
];

      exec-once = [
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE"
        "waybar"
        "hyprpaper"
        "blueman-applet"
      ];
      monitor = [ ",preferred,auto,1" ];
      env = [ "XCURSOR_SIZE,24" ];
      input = {
        kb_layout = "ch";
        kb_variant = "de";
        follow_mouse = 1;
      };


      general = {
        gaps_in     = 5;
        gaps_out    = 20;
        border_size = 2;
        "col.active_border"   = "rgba(ff00ffaa)";
        "col.inactive_border" = "rgba(1a1a1aaa)";
      };
    };

    # here we inject raw hyprland.conf lines that the module
    # doesn’t know about directly
    extraConfig = ''
    animations {
  enabled = yes
  animation = windows, 1500, 0, easeOut
  animation = windowsOut, 2000, 1000, easeInOut
  animation = fade, 2000, 1000, easeInOut

}


    '';
  };

  home.enableNixpkgsReleaseCheck = false;
}
