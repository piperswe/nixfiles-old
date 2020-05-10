{ config, pkgs, lib, fetchurl, ... }:

{
  home.packages = with pkgs; [
    _1password
    python
    leiningen
    wget
    bat
    htop
    mosh
    links
    file
    (lib.mkIf stdenv.isLinux sshfs)
  ];

  home.sessionVariables = {
    TERMINAL = "${pkgs.alacritty}/bin/alacritty";
    EDITOR = "nvim";
    TMUX_TMPDIR = "$HOME/.tmp/tmux";
  };

  home.file.links = let font = "${pkgs.nerdfonts}/share/fonts/truetype/NerdFonts/Fira Code Regular Nerd Font Complete.otf";
  boldFont = "${pkgs.nerdfonts}/share/fonts/truetype/NerdFonts/Fira Code Bold Nerd Font Complete.otf";
  in {
    target = ".links/links.cfg";
    text = ''
      font "${font}"
      font_bold "${boldFont}"
      font_monospaced "${font}"
      font_monospaced_bold "${boldFont}"
      font_italic "${font}"
      font_italic_bold "${boldFont}"
      font_monospaced_italic "${font}"
      font_monospaced_italic_bold "${boldFont}"

      download_dir ""
      language "default"
      max_connections 10
      max_connections_to_host 8
      retries 3
      receive_timeout 120
      unrestartable_receive_timeout 600
      timeout_when_trying_multiple_addresses 3
      bind_address ""
      bind_address_ipv6 ""
      async_dns 1
      download_utime 0
      format_cache_size 5
      memory_cache_size 4M
      image_cache_size 1M
      font_cache_size 2M
      http_bugs.aggressive_cache 1
      ipv6.address_preference 0
      http_proxy ""
      ftp_proxy ""
      https_proxy ""
      socks_proxy ""
      no_proxy_domains ""
      append_text_to_dns_lookups ""
      only_proxies 0
      ssl.certificates 1
      ssl.builtin_certificates 0
      ssl.client_cert_key ""
      ssl.client_cert_crt ""
      http_bugs.http10 0
      http_bugs.allow_blacklist 1
      http_bugs.no_accept_charset 0
      http_bugs.no_compression 0
      http_bugs.retry_internal_errors 0
      fake_firefox 0
      http_do_not_track 0
      http_referer 4
      fake_referer ""
      fake_useragent ""
      http.extra_header ""
      ftp.anonymous_password "somebody@host.domain"
      ftp.use_passive 1
      ftp.use_eprt_epsv 0
      ftp.set_iptos 1
      smb.allow_hyperlinks_to_smb 0
      menu_font_size 16
      background_color 14737632
      foreground_color 0
      scroll_bar_area_color 12632256
      scroll_bar_bar_color 0
      scroll_bar_frame_color 0
      bookmarks_file "/home/pmc/.links/bookmarks.html"
      bookmarks_codepage utf-8
      save_url_history 1
      display_red_gamma 2.200000
      display_green_gamma 2.200000
      display_blue_gamma 2.200000
      user_gamma 1.000000
      bfu_aspect 1.000000
      display_optimize 0
      dither_letters 1
      dither_images 1
      gamma_correction 2
      overwrite_instead_of_scroll 1
      extension "xpm" "image/x-xpixmap"
      extension "xls" "application/excel"
      extension "xbm" "image/x-xbitmap"
      extension "wav" "audio/x-wav"
      extension "tiff,tif" "image/tiff"
      extension "tga" "image/targa"
      extension "sxw" "application/x-openoffice"
      extension "swf" "application/x-shockwave-flash"
      extension "svg" "image/svg+xml"
      extension "sch" "application/gschem"
      extension "rtf" "application/rtf"
      extension "ra,rm,ram" "audio/x-pn-realaudio"
      extension "qt,mov" "video/quicktime"
      extension "ps,eps,ai" "application/postscript"
      extension "ppt" "application/powerpoint"
      extension "ppm" "image/x-portable-pixmap"
      extension "pnm" "image/x-portable-anymap"
      extension "png" "image/png"
      extension "pgp" "application/pgp-signature"
      extension "pgm" "image/x-portable-graymap"
      extension "pdf" "application/pdf"
      extension "pcb" "application/pcb"
      extension "pbm" "image/x-portable-bitmap"
      extension "mpeg,mpg,mpe" "video/mpeg"
      extension "mp3" "audio/mpeg"
      extension "mid,midi" "audio/midi"
      extension "jpg,jpeg,jpe" "image/jpeg"
      extension "grb" "application/gerber"
      extension "gl" "video/gl"
      extension "gif" "image/gif"
      extension "gbr" "application/gerber"
      extension "g" "application/brlcad"
      extension "fli" "video/fli"
      extension "dxf" "application/dxf"
      extension "dvi" "application/x-dvi"
      extension "dl" "video/dl"
      extension "deb" "application/x-debian-package"
      extension "avi" "video/x-msvideo"
      extension "au,snd" "audio/basic"
      extension "aif,aiff,aifc" "audio/x-aiff"
      video_driver "x" "948x1017" "" default 0
    '';
  };

  programs.gpg.enable = true;

  services.gpg-agent = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    enableSshSupport = true;
  };

  programs.git = {
    enable = true;
    userName = "Piper McCorkle";
    userEmail = "contact@piperswe.me";
    lfs.enable = true;
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    plugins = with pkgs; with vimPlugins; [
      vim-nix
      vim-fireplace
      vim-airline
      rainbow_parentheses-vim
      vim-ledger
      (lib.mkIf stdenv.isLinux syntastic)
      vim-fish
      gruvbox
      vim-toml
      rust-vim
    ];
    extraConfig = ''
      syntax enable
      filetype plugin indent on
      let g:gruvbox_italic=1
      set termguicolors
      colorscheme gruvbox
      set mouse=a
      set number
      "let g:syntastic_always_populate_loc_list = 1
      "let g:syntastic_auto_loc_list = 1
      "let g:syntastic_check_on_open = 1
      "let g:syntastic_check_on_wq = 0
      "let g:syntastic_perl_checkers = ['perl', 'perlcritic']
      "let g:syntastic_enable_perl_checker = 1
      let g:airline_powerline_fonts = 1
      let g:ledger_maxwidth = 80
    '';
  };

  programs.fish = {
    enable = true;
    shellInit = ''
      set -gx EDITOR nvim
      alias ssh "${pkgs.ssh-ident}/bin/ssh-ident"
    '';
    promptInit = ''
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
      theme_gruvbox dark
      ${pkgs.starship}/bin/starship init fish | source
    '';
    functions = {
      fish_greeting = ''
        cat ${./greeting.txt}
        ${pkgs.pfetch}/bin/pfetch
      '';
    };
    plugins = [
      {
        name = "foreign-env";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-foreign-env";
          rev = "dddd9213272a0ab848d474d0cbde12ad034e65bc";
          sha256 = "00xqlyl3lffc5l0viin1nyp819wf81fncqyz87jx8ljjdhilmgbs";
        };
      }
      {
        name = "bobthefish";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "theme-bobthefish";
          rev = "6e75f31c3fd10944b108b0338e855a993bad17c9";
          sha256 = "0qn4pr6l7fbljnl8jjgm0mdw1rjdv9mc8y7wpk7rcnkkaqrd457r";
        };
      }
      {
        name = "gruvbox";
        src = pkgs.fetchFromGitHub {
          owner = "jomik";
          repo = "fish-gruvbox";
          rev = "d8c0463518fb95bed8818a1e7fe5da20cffe6fbd";
          sha256 = "0hkps4ddz99r7m52lwyzidbalrwvi7h2afpawh9yv6a226pjmck7";
        };
      }
    ];
  };

  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      battery
      gruvbox
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
        '';
      }
      cpu
      {
        plugin = resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
    ];
  };

  services.keybase.enable = pkgs.stdenv.isLinux;
  services.kbfs.enable = pkgs.stdenv.isLinux;

  #programs.ledger = {
  #  enable = true;
  #  file = "${config.home.homeDirectory}/Documents/ledger/data.journal";
  #  priceDB = "${config.home.homeDirectory}/Documents/ledger/prices.journal";
  #  extraConfig = ''
  #    --sort date
  #  '';
  #};

  home.file = {
    ".lein/profiles.clj".text = ''
      {:user {:plugins [[cider/cider-nrepl "0.24.0"]]}}
    '';
    ".lein/credentials.clj.gpg".source = ./lein/credentials.clj.gpg;
    ".config/starship.toml".text = ''
      [hostname]
      disabled = false
      trim_at = ".hodgepodge.dev"
    '';
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.03";
}
