{ config, pkgs, lib, ... }:
let
  desktopBackground = pkgs.fetchurl {
    url = "https://images.unsplash.com/photo-1555021890-2a10a279e77d";
    sha256 = "126p15w8li4gzsa9qkjyzi1rkhj6yyyj9y8wdgi3fhlpq227pn9n";
  };
  ifLinux = lib.mkIf pkgs.stdenv.isLinux;
  ifAMD64 = lib.mkIf pkgs.stdenv.isx86_64;
  ifLinuxAMD64 = lib.mkIf (pkgs.stdenv.isLinux && pkgs.stdenv.isx86_64);
  terminal = if !pkgs.stdenv.isx86_64 then "${pkgs.termite}/bin/termite" else "${pkgs.alacritty}/bin/alacritty";
  i3Config = rec {
    fonts = [ "Monoid Nerd Font" ];
    modifier = "Mod4";
    keybindings = lib.mkOptionDefault {
      "${modifier}+p" = "exec rofi -show drun";
      "${modifier}+Return" = "exec ${terminal}";
    };
    bars = [
      {
        fonts = [ "Monoid Nerd Font" ];
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
  customSteam = pkgs.steam.override { nativeOnly = true; };
  netsurf-fb = pkgs.writeScriptBin "netsurf-fb" ''
    #! ${pkgs.bash}/bin/bash
    exec ${pkgs.netsurf.browser}/bin/netsurf-fb
  '';
in
{
  home.sessionVariables.TERMINAL = terminal;
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    (ifLinux cantata)
    (ifLinuxAMD64 minecraft)
    (ifLinuxAMD64 multimc)
    (ifLinuxAMD64 obs-studio)
    (ifLinuxAMD64 customSteam)
    (ifLinuxAMD64 customSteam.run)
    (ifLinux xfce.thunar)
    (ifLinux xfce.thunar-archive-plugin)
    (ifLinux gnome3.file-roller)
    (ifLinuxAMD64 jetbrains.idea-ultimate)
    (ifLinuxAMD64 jetbrains.datagrip)
    (ifLinuxAMD64 jetbrains.goland)
    (ifLinux riot-desktop)
    (ifLinux tdesktop)
    (ifLinuxAMD64 discord)
    (ifLinux vlc)
    (ifLinux gnome3.gnome-keyring)
    mpv
    (ifLinux keybase-gui)
    qdirstat
    (ifLinuxAMD64 spotify)
    (ifLinuxAMD64 postman)
    netsurf-fb
    (netsurf.browser.override {
      uilib = "gtk";
    })

    (pkgs.callPackage ./nerdfonts {
      fonts = [
        "Monoid"
      ];
    }
    )
    ibm-plex
    noto-fonts-cjk
    noto-fonts-emoji
    unifont
    unifont_upper
    freefont_ttf
    (pkgs.stdenv.mkDerivation {
      name = "open-sans-emoji";
      src = builtins.fetchTarball {
        url = "https://github.com/MorbZ/OpenSansEmoji/archive/e76f1200b1892f1e154fe844671ac391ed433f9f.tar.gz";
        sha256 = "00kq9x1v9mmgjvz1p7al3kgpwk6jvgdwhxv5y45c1q0ssyi0ihiw";
      };
      installPhase = ''
        mkdir -p $out/share/fonts/{truetype,opentype}
        cp $src/OpenSansEmoji.otf $out/share/fonts/opentype
        cp $src/OpenSansEmoji.ttf $out/share/fonts/truetype
      '';
    })

    libreoffice-fresh
    mupdf

    virt-manager
    (ifLinuxAMD64 (pkgs.callPackage ./github-classroom-assistant.nix { }))
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

  programs.termite = {
    enable = !pkgs.stdenv.isx86_64;
    dynamicTitle = true;
    font = "Monoid Nerd Font 12";
  };

  programs.alacritty = {
    enable = pkgs.stdenv.isx86_64;
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
    windowManager.i3 = {
      enable = true;
      config = i3Config // {
        startup = [
          {
            command = ''${pkgs.feh}/bin/feh --no-fehbg --bg-scale "${desktopBackground}"'';
            notification = false;
          }
        ];
      };
    };
  };

  home.file.".xinitrc" = {
    text = ''
      #! ${pkgs.bash}/bin/bash
      exec bash ~/.xsession
    '';
    executable = true;
  };

  wayland.windowManager.sway = ifLinux {
    enable = true;
    config = i3Config // {
      startup = [
        {
          command = ''${pkgs.swaybg}/bin/swaybg -i "${desktopBackground}" -m fill'';
        }
      ];
    };
  };

  #programs.fish.loginShellInit = ifLinux ''
  #  # If running from tty1 start sway
  #  set TTY1 (tty)
  #  if test -z "$DISPLAY"; and test $TTY1 = "/dev/tty1"
  #    exec ${pkgs.sway}/bin/sway
  #  end
  #'';

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

  programs.vscode = {
    enable = false;
    userSettings = {
      "extensions.autoUpdate" = false;
      "extensions.autoCheckUpdates" = false;
      "update.showReleaseNotes" = false;
      "update.mode" = "none";
      "editor.rulers" = [ 72 ];
      "window.titleBarStyle" = "custom";
    };
    extensions = with pkgs; with vscode-extensions; [
      bbenoist.Nix
      justusadam.language-haskell
      ms-vscode.cpptools
      ms-vscode-remote.remote-ssh
      ms-python.python
      scala-lang.scala
      skyapps.fish-vscode
      (vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "rust";
          publisher = "rust-lang";
          version = "0.7.8";
          sha256 = "039ns854v1k4jb9xqknrjkj8lf62nfcpfn0716ancmjc4f0xlzb3";
        };
        meta = {
          license = with stdenv.lib.licenses; [ mit asl20 ];
        };
      })
      (vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "elm-ls-vscode";
          publisher = "Elmtooling";
          version = "0.10.2";
          sha256 = "17y52hapkfgbvy4g7gd1ac59v9ppspqa8cqgq21pskzcmgplcign";
        };
        meta = {
          license = stdenv.lib.licenses.mit;
        };
      })
      (vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "calva";
          publisher = "betterthantomorrow";
          version = "2.0.101";
          sha256 = "17p9mwr3rs052snflraiqrid8kgql5972av3q6dp7bplpc2bnhzk";
        };
        meta = {
          license = stdenv.lib.licenses.mit;
        };
      })
      (vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "clj-kondo";
          publisher = "borkdude";
          version = "2020.5.9";
          sha256 = "0jnnkrmnjzr1fhvfwsdqwimnm2r7vwn8s7sv8n14i1vp1lm3dw3d";
        };
        meta = {
          license = stdenv.lib.licenses.epl10;
        };
      })
    ];
  };

  services.gpg-agent.pinentryFlavor = lib.mkForce "gtk2";

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/discord-472164236332630018" = ifLinuxAMD64 "discord-472164236332630018.desktop";
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
    };
  };
}
