{ config, pkgs, lib, ... }:

let desktopBackground = pkgs.fetchurl {
  url = "https://images.unsplash.com/photo-1555021890-2a10a279e77d";
  sha256 = "126p15w8li4gzsa9qkjyzi1rkhj6yyyj9y8wdgi3fhlpq227pn9n";
};
in {
  home.packages = [
    (lib.mkIf pkgs.stdenv.isLinux pkgs.cantata)
    (lib.mkIf pkgs.stdenv.isLinux pkgs.minecraft)
    (lib.mkIf pkgs.stdenv.isLinux pkgs.multimc)
    (lib.mkIf pkgs.stdenv.isLinux pkgs.obs-studio)
    (lib.mkIf pkgs.stdenv.isLinux (pkgs.steam.override { nativeOnly = true; }))
    (lib.mkIf pkgs.stdenv.isLinux pkgs.xfce.thunar)
    (lib.mkIf pkgs.stdenv.isLinux pkgs.xfce.thunar-archive-plugin)
    (lib.mkIf pkgs.stdenv.isLinux pkgs.gnome3.file-roller)
    (lib.mkIf pkgs.stdenv.isLinux pkgs.jetbrains.idea-ultimate)
    (lib.mkIf pkgs.stdenv.isLinux pkgs.android-studio)
    (lib.mkIf pkgs.stdenv.isLinux pkgs.riot-desktop)
    (lib.mkIf pkgs.stdenv.isLinux pkgs.tdesktop)
    (lib.mkIf pkgs.stdenv.isLinux pkgs.discord)
    (lib.mkIf pkgs.stdenv.isLinux pkgs.zoom-us)
    (lib.mkIf pkgs.stdenv.isLinux pkgs.vlc)
    pkgs.mpv

    (lib.mkIf pkgs.stdenv.isLinux pkgs.abiword)
    (lib.mkIf pkgs.stdenv.isLinux pkgs.gnumeric)
  ];

  programs.firefox = lib.mkIf pkgs.stdenv.isLinux {
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

  programs.rofi = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    extraConfig = "rofi.modi: drun";
  };

  xsession = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    initExtra = ''${pkgs.feh}/bin/feh --no-fehbg --bg-scale "${desktopBackground}" &'';
    windowManager.i3 = {
      enable = true;
      config = {
        fonts = ["IBM Plex Sans"];
        keybindings = lib.mkOptionDefault {
          "Mod1+p" = "exec rofi -show drun";
        };
        bars = [
          {
            position = "bottom";
            statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${./i3status-rust.toml}";
          }
        ];
      };
    };
  };
}
