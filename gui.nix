{ config, pkgs, lib, ... }:
let
  desktopBackground = pkgs.fetchurl {
    url = "https://images.unsplash.com/photo-1555021890-2a10a279e77d";
    sha256 = "126p15w8li4gzsa9qkjyzi1rkhj6yyyj9y8wdgi3fhlpq227pn9n";
  };
  ifLinux = lib.mkIf pkgs.stdenv.isLinux;
  i3status-rust = pkgs.callPackage ./i3status-rust.nix { };
  i3Config = {
    fonts = [ "Monoid Nerd Font" ];
    modifier = "Mod4";
    keybindings = lib.mkOptionDefault {
      "Mod4+p" = "exec rofi -show drun";
    };
    bars = [
      {
        fonts = [ "Monoid Nerd Font" ];
        position = "bottom";
        statusCommand = "${i3status-rust}/bin/i3status-rs ${./i3status-rust.toml}";
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
  customSteam = pkgs.steam.override { nativeOnly = true; };
in
{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    (ifLinux cantata)
    (ifLinux minecraft)
    (ifLinux multimc)
    (ifLinux obs-studio)
    (ifLinux customSteam)
    (ifLinux customSteam.run)
    (ifLinux xfce.thunar)
    (ifLinux xfce.thunar-archive-plugin)
    (ifLinux gnome3.file-roller)
    (ifLinux jetbrains.idea-ultimate)
    (ifLinux riot-desktop)
    (ifLinux tdesktop)
    (ifLinux discord)
    (ifLinux vlc)
    (ifLinux gnome3.gnome-keyring)
    mpv
    (ifLinux keybase-gui)
    qdirstat
    (ifLinux spotify)

    nerdfonts
    ibm-plex

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
      config = i3Config;
    };
  };

  wayland.windowManager.sway = ifLinux {
    enable = true;
    config = i3Config;
  };

  programs.fish.loginShellInit = ifLinux ''
    # If running from tty1 start sway
    set TTY1 (tty)
    if test -z "$DISPLAY"; and test $TTY1 = "/dev/tty1"
      exec ${pkgs.sway}/bin/sway
    end
  '';

  # If this doesn't work, add this to your system configuration:
  # programs.dconf.enable = true;
  gtk = {
    enable = true;
    theme = {
      package = pkgs.arc-theme;
      name = "Arc-Darker";
    };
    iconTheme = {
      package = pkgs.arc-icon-theme;
      name = "Arc";
    };
    font = {
      name = "Monoid Nerd Font";
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/discord-472164236332630018" = "discord-472164236332630018.desktop";
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
    };
  };
}
