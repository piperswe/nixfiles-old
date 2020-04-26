{ config, pkgs, lib, ... }:

let desktopBackground = pkgs.fetchurl {
  url = "https://images.unsplash.com/photo-1555021890-2a10a279e77d";
  sha256 = "126p15w8li4gzsa9qkjyzi1rkhj6yyyj9y8wdgi3fhlpq227pn9n";
};
in {
  home.packages = [
    pkgs.mpc_cli
    pkgs.cantata
    pkgs.minecraft
    pkgs.multimc
    pkgs.obs-studio
    (pkgs.steam.override { nativeOnly = true; })
    pkgs.xfce.thunar
  ];

  programs.firefox = {
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

  services.mpd = {
    enable = true;
    musicDirectory = "${config.home.homeDirectory}/Music";
    playlistDirectory = "${config.home.homeDirectory}/Music/playlists";
  };
  services.mpdris2 = {
    enable = true;
    mpd.musicDirectory = "${config.home.homeDirectory}/Music";
  };

  programs.alacritty.enable = true;

  programs.rofi = {
    enable = true;
    extraConfig = "rofi.modi: drun";
  };

  xsession = {
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
