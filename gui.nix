{ config, pkgs, lib, ... }:

let desktopBackground = pkgs.fetchurl {
  url = "https://images.unsplash.com/photo-1555021890-2a10a279e77d";
  sha256 = "126p15w8li4gzsa9qkjyzi1rkhj6yyyj9y8wdgi3fhlpq227pn9n";
};
ifLinux = lib.mkIf pkgs.stdenv.isLinux;
in {
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    (ifLinux cantata)
    (ifLinux minecraft)
    (ifLinux multimc)
    (ifLinux obs-studio)
    (ifLinux (steam.override { nativeOnly = true; }))
    (ifLinux xfce.thunar)
    (ifLinux xfce.thunar-archive-plugin)
    (ifLinux gnome3.file-roller)
    (ifLinux jetbrains.idea-ultimate)
    (ifLinux android-studio)
    (ifLinux riot-desktop)
    (ifLinux tdesktop)
    (ifLinux discord)
    (ifLinux zoom-us)
    (ifLinux vlc)
    mpv

    nerdfonts
    powerline-fonts
    ibm-plex
    fira-code
    fira-code-symbols

    (ifLinux abiword)
    (ifLinux gnumeric)
  ];

  programs.firefox = ifLinux {
    enable = true;
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      https-everywhere
      privacy-badger
      ublock-origin
      multi-account-containers
      reddit-enhancement-suite
    ];
    profiles."Piper" = {
      name = "Piper";
      id = 0;
      isDefault = true;
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal.family = "Monoid Nerd Font";
        bold.family = "Monoid Nerd Font";
        italic.family = "Monoid Nerd Font";
      };
      colors = {
        primary = {
          background = "#282828";
          foreground = "#ebdbb2";
        };
        normal = {
          black = "#282828";
          red = "#cc241d";
          green = "#98971a";
          yellow = "#d7992a";
          blue = "#458588";
          magenta = "#b16286";
          cyan = "#689d6a";
          white = "#a89984";
        };
        bright = {
          black = "#928374";
          red = "#fb4934";
          green = "#b8bb26";
          yellow = "#fabd2f";
          blue = "#83a598";
          magenta = "#d3869b";
          cyan = "#8ec07c";
          white = "#ebdbb2";
        };
      };
    };
  };

  programs.rofi = ifLinux {
    enable = true;
    extraConfig = "rofi.modi: drun";
  };

  xsession = ifLinux {
    enable = true;
    initExtra = ''${pkgs.feh}/bin/feh --no-fehbg --bg-scale "${desktopBackground}" &'';
    windowManager.i3 = {
      enable = true;
      config = {
        fonts = ["Monoid Nerd Font"];
        keybindings = lib.mkOptionDefault {
          "Mod1+p" = "exec rofi -show drun";
        };
        bars = [
          {
            position = "bottom";
            statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${./i3status-rust.toml}";
            colors = {
              background = "#282828";
              statusline = "#ebdbb2";
            };
          }
        ];
        colors = {
          focused = rec {
            border = "#458588";
            text = "#ebdbb2";
            background = border;
            indicator = border;
            childBorder = border;
          };
          focusedInactive = rec {
            border = "#83a598";
            text = "#ebdbb2";
            background = border;
            indicator = border;
            childBorder = border;
          };
          unfocused = rec {
            border = "#928374";
            text = "#ebdbb2";
            background = border;
            indicator = border;
            childBorder = border;
          };
        };
      };
    };
  };
}
