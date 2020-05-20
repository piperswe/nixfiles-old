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
    screen
    unzip
    bind
    nixpkgs-fmt
    (rustPlatform.buildRustPackage rec {
      pname = "zenith";
      version = "bf8bb61460e6dc8089a05a4eefca78d684189d6d";

      src = fetchFromGitHub {
        owner = "bvaisvil";
        repo = pname;
        rev = version;
        sha256 = "0s20vjm8irlbw8z611qwfxwr6m1zqq9l3zr2dh65dl95b6v1k3fd";
      };

      cargoSha256 = "1jgr4i3bdgjhfy6af1m34qh6fkzf64prldf2d4vc1rii037zvx7s";

      meta = with stdenv.lib; {
        description = "Sort of like top or htop but with zoom-able charts, network, and disk usage";
        homepage = "https://github.com/bvaisvil/zenith";
        license = licenses.mit;
        platforms = platforms.all;
      };
    })
    nodejs
    (import (builtins.fetchTarball "https://cachix.org/api/v1/install") { }).cachix
    nixpkgs-review
    (lib.mkIf stdenv.isLinux sshfs)
  ];

  home.sessionVariables = {
    TERMINAL = "${pkgs.alacritty}/bin/alacritty";
    EDITOR = "nvim";
    TMUX_TMPDIR = "$HOME/.tmp/tmux";
  };

  home.file.links =
    let
      font = "${pkgs.nerdfonts}/share/fonts/truetype/NerdFonts/Fira Code Regular Nerd Font Complete.otf";
      boldFont = "${pkgs.nerdfonts}/share/fonts/truetype/NerdFonts/Fira Code Bold Nerd Font Complete.otf";
    in
    {
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
      vim-fish
      gruvbox
      vim-toml
      rust-vim
      coc-nvim
      coc-json
      nerdtree
    ];
    extraConfig = ''
      syntax enable
      filetype plugin indent on
      let g:gruvbox_italic=1
      set termguicolors
      colorscheme gruvbox
      set mouse=a
      set number
      let g:airline_powerline_fonts = 1
      let g:ledger_maxwidth = 80

      " TextEdit might fail if hidden is not set.
      set hidden

      " Some servers have issues with backup files, see #649.
      set nobackup
      set nowritebackup

      " Give more space for displaying messages.
      set cmdheight=2

      " Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
      " delays and poor user experience.
      set updatetime=300

      " Don't pass messages to |ins-completion-menu|.
      set shortmess+=c

      " Always show the signcolumn, otherwise it would shift the text each time
      " diagnostics appear/become resolved.
      set signcolumn=yes

      " Use tab for trigger completion with characters ahead and navigate.
      " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
      " other plugin before putting this into your config.
      inoremap <silent><expr> <TAB>
            \ pumvisible() ? "\<C-n>" :
            \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
      inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

      function! s:check_back_space() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~# '\s'
      endfunction

      " Use <c-space> to trigger completion.
      inoremap <silent><expr> <c-space> coc#refresh()

      " Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
      " position. Coc only does snippet and additional edit on confirm.
      " <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
      if exists('*complete_info')
        inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
      else
        inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
      endif

      " Use `[g` and `]g` to navigate diagnostics
      nmap <silent> [g <Plug>(coc-diagnostic-prev)
      nmap <silent> ]g <Plug>(coc-diagnostic-next)

      " GoTo code navigation.
      nmap <silent> gd <Plug>(coc-definition)
      nmap <silent> gy <Plug>(coc-type-definition)
      nmap <silent> gi <Plug>(coc-implementation)
      nmap <silent> gr <Plug>(coc-references)

      " Use K to show documentation in preview window.
      nnoremap <silent> K :call <SID>show_documentation()<CR>

      function! s:show_documentation()
        if (index(['vim','help'], &filetype) >= 0)
          execute 'h '.expand('<cword>')
        else
          call CocAction('doHover')
        endif
      endfunction

      " Highlight the symbol and its references when holding the cursor.
      autocmd CursorHold * silent call CocActionAsync('highlight')

      " Symbol renaming.
      nmap <leader>rn <Plug>(coc-rename)

      " Formatting selected code.
      xmap <leader>f  <Plug>(coc-format-selected)
      nmap <leader>f  <Plug>(coc-format-selected)

      augroup mygroup
        autocmd!
        " Setup formatexpr specified filetype(s).
        autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
        " Update signature help on jump placeholder.
        autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
      augroup end

      " Applying codeAction to the selected region.
      " Example: `<leader>aap` for current paragraph
      xmap <leader>a  <Plug>(coc-codeaction-selected)
      nmap <leader>a  <Plug>(coc-codeaction-selected)

      " Remap keys for applying codeAction to the current line.
      nmap <leader>ac  <Plug>(coc-codeaction)
      " Apply AutoFix to problem on the current line.
      nmap <leader>qf  <Plug>(coc-fix-current)

      " Map function and class text objects
      " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
      xmap if <Plug>(coc-funcobj-i)
      omap if <Plug>(coc-funcobj-i)
      xmap af <Plug>(coc-funcobj-a)
      omap af <Plug>(coc-funcobj-a)
      xmap ic <Plug>(coc-classobj-i)
      omap ic <Plug>(coc-classobj-i)
      xmap ac <Plug>(coc-classobj-a)
      omap ac <Plug>(coc-classobj-a)

      " Use CTRL-S for selections ranges.
      " Requires 'textDocument/selectionRange' support of LS, ex: coc-tsserver
      nmap <silent> <C-s> <Plug>(coc-range-select)
      xmap <silent> <C-s> <Plug>(coc-range-select)

      " Add `:Format` command to format current buffer.
      command! -nargs=0 Format :call CocAction('format')
      
      " Add `:Fold` command to fold current buffer.
      command! -nargs=? Fold :call     CocAction('fold', <f-args>)

      " Add `:OR` command for organize imports of the current buffer.
      command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')
      
      " Add (Neo)Vim's native statusline support.
      " NOTE: Please see `:h coc-status` for integrations with external plugins that
      " provide custom statusline: lightline.vim, vim-airline.
      " set statusline^=%{coc#status()}%{get(b:,'coc_current_function',\'\')}

      " Mappings using CoCList:
      " Show all diagnostics.
      nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
      " Manage extensions.
      nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
      " Show commands.
      nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
      " Find symbol of current document.
      nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
      " Search workspace symbols.
      nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
      " Do default action for next item.
      nnoremap <silent> <space>j  :<C-u>CocNext<CR>
      " Do default action for previous item.
      nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
      " Resume latest coc list.
      nnoremap <silent> <space>p  :<C-u>CocListResume<CR>
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
      [nix_shell]
      use_name = true
    '';
  };

  xdg.configFile."nvim/coc-settings.json".text = builtins.toJSON {
    languageserver = {
      haskell = {
        command =
          let all-hies = import (fetchTarball "https://github.com/infinisil/all-hies/tarball/master") { };
          in "${all-hies.selection { selector = p: { inherit (p) ghc844 ghc865 ghc882; }; }}/bin/hie-wrapper";
        args = [ "--lsp" ];
        rootPatterns = [
          "*.cabal"
          "stack.yaml"
          "cabal.project"
          "package.yaml"
        ];
        filetypes = [
          "hs"
          "lhs"
          "haskell"
        ];
        initializationOptions.languageServerHaskell = { };
      };
      clojure = {
        command = "${pkgs.jre}/bin/java";
        args = [ "-Xmx1g" "-server" "-Dclojure-lsp.version=0.1.0-SNAPSHOT" "-jar" "${pkgs.clojure-lsp}/bin/clojure-lsp" ];
        filetypes = [
          "clojure"
          "clj"
          "cljc"
          "cljs"
        ];
        rootPatterns = [ "project.clj" ];
        additionalSchemes = [ "jar" "zipfile" ];
        "trace.server" = "verbose";
        initializationOptions = { };
      };
      nix = {
        command =
          let
            tar = "https://github.com/nix-community/rnix-lsp/archive/75eb3a656c633efe6522303f92ac33c1c3d697f6.tar.gz";
            rnix-lsp = pkgs.callPackage (builtins.fetchTarball tar) { };
          in
          "${rnix-lsp}/bin/rnix-lsp";
        filetypes = [
          "nix"
        ];
      };
    };
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
