{ config, pkgs, lib, fetchurl, ... }:

{
  home.packages = [
    pkgs.mpc_cli
    pkgs.cantata
    pkgs.minecraft
    pkgs.multimc
    pkgs.obs-studio
    (pkgs.steam.override { nativeOnly = true; })
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
    initExtra = ''${pkgs.feh}/bin/feh --no-fehbg --bg-scale "${config.home.homeDirectory}/.config/nixpkgs/desktop-background.jpg" &'';
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
