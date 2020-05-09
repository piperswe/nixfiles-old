{ config, pkgs, lib, fetchurl, ... }:

{
  home.packages = with pkgs; [
    any-nix-shell
    _1password
    python
    leiningen
    wget
    bat
    htop
    (lib.mkIf stdenv.isLinux sshfs)
  ];

  home.sessionVariables = {
    TERMINAL = "${pkgs.alacritty}/bin/alacritty";
    EDITOR = "nvim";
    TMUX_TMPDIR = "$HOME/.tmp/tmux";
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
      any-nix-shell fish --info-right | source
      theme_gruvbox dark
    '';
    functions = {
      fish_greeting = ''
        cat ${./greeting.txt}
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
      `}
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
