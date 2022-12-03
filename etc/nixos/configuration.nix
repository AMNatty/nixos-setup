{config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-22.11.tar.gz";
  nvim-cfg = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    coc = {
      enable = true;
      settings = {
        languageserver = {
          haskell = {
            command = "haskell-language-server-wrapper";
            args = [ "--lsp" ];
            rootPatterns = [
              "*.cabal"
              "stack.yaml"
              "package.yaml"
            ];
            filetypes = [ "hs" "lhs" "haskell" "lhaskell" ];
          };
        };
      };
    };
    plugins = with pkgs.vimPlugins; [
      editorconfig-nvim
      lualine-nvim
      lualine-lsp-progress
      nvim-web-devicons
      vim-devicons
      onedark-nvim
      barbar-nvim
      vim-better-whitespace
      nerdtree
      nerdtree-git-plugin
      vim-nix
      coc-rust-analyzer
      coc-nvim
      coc-json
      coc-java
      coc-nginx
      coc-emmet
      coc-cmake
      coc-clangd
      coc-prettier
      coc-sh
      coc-python
    ];
    extraConfig = ''
      nnoremap <silent> <C-S> <CMD>w<CR>
      inoremap <silent> <C-S> <ESC><CMD>w<CR>
      " nnoremap <silent> <C-w> <CMD>BufferClose<CR>

      nmap <C-BS> <CMD>db<CR>
      imap <C-BS> <C-w>

      nnoremap <C-DEL> dw
      inoremap <C-DEL> <C-O>dw

      nnoremap <Tab> >>

      nnoremap <S-Tab> <<
      inoremap <S-Tab> <C-d>

      nmap <S-Up> v<Up>
      nmap <S-Down> v<Down>
      nmap <S-Left> v<Left>
      nmap <S-Right> v<Right>
      vmap <S-Up> <Up>
      vmap <S-Down> <Down>
      vmap <S-Left> <Left>
      vmap <S-Right> <Right>
      imap <S-Up> <Esc>v<Up>
      imap <S-Down> <Esc>v<Down>
      imap <S-Left> <Esc>v<Left>
      imap <S-Right> <Esc>v<Right>

      set backspace=indent,eol,start

      set shiftwidth=4
      set expandtab
      set tabstop=4
      set smartindent
      set autoindent
      set cpoptions+=I
      set nowrap
      set clipboard+=unnamedplus
      set mouse=a
      set number relativenumber
      set nu rnu

      set guifont=Cascadia\ Code:h12
      set number
      set whichwrap=<,>,[,]
      highlight LineNr ctermfg=darkgray

      nmap <silent> <c-k> :wincmd k<CR>
      nmap <silent> <c-i> :wincmd j<CR>
      nmap <silent> <c-j> :wincmd h<CR>
      nmap <silent> <c-l> :wincmd l<CR>

      nnoremap <C-t> <CMD>NERDTreeToggle<CR>

      " Use <c-space> to trigger completion.
      if has('nvim')
        inoremap <silent><expr> <c-space> coc#refresh()
      else
        inoremap <silent><expr> <c-@> coc#refresh()
      endif

      " Make <CR> to accept selected completion item or notify coc.nvim to format
      " <C-g>u breaks current undo, please make your own choice.
      inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                                    \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

      " Start NERDTree. If a file is specified, move the cursor to its window.
      autocmd StdinReadPre * let s:std_in=1
      autocmd VimEnter * NERDTree | if argc() > 0 || exists("s:std_in") | wincmd p | endif

      " Exit Vim if NERDTree is the only window remaining in the only tab.
      autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

      " Close the tab if NERDTree is the only window remaining in it.
      autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

      lua << END
      require('lualine').setup {
        options = {
          icons_enabled = true,
          theme = 'dracula',
          component_separators = { left = '', right = ''},
          section_separators = { left = '', right = ''},
          disabled_filetypes = {
            statusline = {},
            winbar = {},
          },
          ignore_focus = {},
          always_divide_middle = true,
          globalstatus = false,
          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
          }
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff', 'diagnostics'},
          lualine_c = {'filename'},
          lualine_x = {'encoding', 'fileformat', 'filetype'},
          lualine_y = {'progress'},
          lualine_z = {'location'}
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {'filename'},
          lualine_x = {'location'},
          lualine_y = {},
          lualine_z = {}
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = {}
      }

      require('editorconfig').properties.foo = function(bufnr, val)
        vim.b[bufnr].foo = val
      end

      require('onedark').setup {
          style = 'deep'
      }
      require('onedark').load()

      END
    '';
  };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./fstab.nix
      (import "${home-manager}/nixos")
    ];

  nixpkgs.overlays = [ (self: super: {
    hls942 = pkgs.haskell-language-server.override { supportedGhcVersions = [ "942" ]; };
  }) ];

  nix.settings.experimental-features = [ "nix-command" ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "natty-nixos";

  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
  };

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  # Select internationalisation properties.
  i18n.defaultLocale = "cs_CZ.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "cz-qwertz";
  # useXkbConfig = true; # use xkbOptions in tty.
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  hardware.pulseaudio.enable = false;

  # PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  # systemd-resolved
  services.resolved.enable = true;

  # Gnome
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Flatpak
  services.flatpak.enable = true;

  environment.gnome.excludePackages = (with pkgs; [
    gnome-tour
  ]) ++ (with pkgs.gnome; [
    cheese
    gnome-music
    epiphany
    geary
    totem
    tali
    iagno
    hitori
    atomix
  ]);

  # Configure keymap in X11
  services.xserver.layout = "cz";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable Zsh
  programs.zsh.enable = true;

  virtualisation.docker.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.natty = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
    packages = with pkgs; [
      firefox-wayland
      thunderbird
      neofetch
      gnome.gnome-tweaks
      gnome.gnome-terminal
      parted
      unixtools.fdisk
      xdg-desktop-portal-gnome
      obs-studio
    ];
    shell = pkgs.zsh;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    neovim
    wget
    ntfs3g
    htop
    clang
    gcc
    cmake
    llvm
    lld
    rustc
    cargo
    rustfmt
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable dconf because the wiki says so :3
  programs.dconf.enable = true;

  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

  # For zsh completion
  environment.pathsToLink = [ "/share/zsh" ];

  # For Electron garbage
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  nixpkgs.config.allowUnfree = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "22.11";

  home-manager.users.root = {
    home.stateVersion = "22.11";

    programs.neovim = nvim-cfg;
  };

  home-manager.users.natty = {
    home.stateVersion = "22.11";

    home.username = "natty";
    home.homeDirectory = "/home/natty";

    xdg = {
      enable = true;
      userDirs = {
        enable = true;
        createDirectories = true;
        documents = "/drives/personal/Documents";
        music = "/drives/personal/Music";
        pictures = "/drives/personal/Images";
        videos = "/drives/storage/Videos";
      };
    };

    programs.home-manager.enable = true;

    home.packages = with pkgs; [
      dconf
      terminus-nerdfont
      cascadia-code
      gimp
      inkscape
      celluloid
      youtube-dl
      yt-dlp
      roboto
      adw-gtk3
      papirus-icon-theme
      gnome.dconf-editor
      discord
      ffmpeg
      noto-fonts
      noto-fonts-extra
      noto-fonts-cjk-sans
      haskell.compiler.ghc942
      haskellPackages.cabal-install
      haskellPackages.stack
      hls942
      jetbrains-mono
      obsidian
      filezilla
      gnomeExtensions.appindicator
      gnomeExtensions.dash-to-panel
      gnomeExtensions.places-status-indicator
      gnomeExtensions.blur-my-shell
      gnomeExtensions.arcmenu
      python311
      rust-analyzer
      neovide
    ];

    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
    };

    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      extensions = with pkgs.vscode-extensions; [
        redhat.java
        bbenoist.nix
        matklad.rust-analyzer
        haskell.haskell
        justusadam.language-haskell
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "vscode-theme-onedark";
        publisher = "akamud";
        version = "2.3.0";
        sha256 = "f061afe0be29a136237640f067180d61a8ee126201e571759a124cc4ed87a3ce";
      }];
      userSettings = {
        "editor.fontFamily" = "'Cascadia Code', 'monospace', monospace";
        "editor.fontLigatures" = true;
        "terminal.integrated.fontFamily" = "TerminessTTF Nerd Font";
        "terminal.integrated.fontSize" = 16;
        "editor.bracketPairColorization.enabled" = false;
        "redhat.telemetry.enabled" = false;
        "editor.formatOnSave" = true;
        "editor.formatOnType" = true;
        "editor.inlayHints.fontFamily" = "Roboto";
        "editor.inlayHints.fontSize" = 13;
        "editor.inlayHints.padding" = true;
        "[rust]" = {
          "editor.defaultFormatter" = "rust-lang.rust-analyzer";
          "editor.formatOnSave" = true;
        };
        "editor.semanticTokenColorCustomizations" = {
        "[Atom One Dark]" = {
          enabled = true;
          rules = {
            parameter = "#D19A66";
            enumMember = "#D19A66";
            builtinType = "#E5C07B";
            operator = "#ABB2BF";
            lifetime = "#56B6C2";
            variable = "#ABB2BF";
            "variable.constant" = "#d19a66";
            "*.mutable" = {
              underline = true;
            };
            "*.attribute" = {
              italic = true;
            };
            "*.consuming" = {
              bold = true;
            };
            formatSpecifier = "#00d9ff";
            derive = "#61AFEF";
            decorator = "#E5C07B";
            colon = "#ABB2BF";
            namespace = "#9197a3";
          };
        };
      };
      "rust-analyzer.checkOnSave.command" = "clippy";
      "workbench.colorTheme" = "Atom One Dark";
      "haskell.manageHLS" = "PATH";
      "haskell.serverExecutablePath" = "/home/natty/.nix-profile/bin/haskell-language-server-wrapper";
      "editor.inlineSuggest.enabled" = true;
        "git.autofetch" = true;
      };
    };

    programs.gnome-terminal = {
      enable = true;
      profile = {
        d75effea-afab-4286-967b-277c7c6e496a = {
          visibleName = "Default";
          font = "TerminessTTF Nerd Font Medium 12";
          default = true;
        };
      };
      themeVariant = "dark";
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu:minimize,maximize,close";
      };
      "org/gnome/mutter" = {
        edge-tiling = true;
	      dynamic-workspaces = true;
      };
      "org/gnome/shell".enabled-extensions = with pkgs.gnomeExtensions; [
        blur-my-shell.extensionUuid
        appindicator.extensionUuid
        dash-to-panel.extensionUuid
        places-status-indicator.extensionUuid
      ];
      "org/gnome/settings-daemon/plugins/power".sleep-inactive-ac-type = "nothing";
      "org/gtk/gtk4/settings/file-chooser" = {
        show-hidden = true;
        sort-directories-first = true;
      };
    };

    programs.git = {
      enable = true;
      userName  = "Natty";
      userEmail = "natty.sh.git@gmail.com";
      signing = {
        key = "BF6CB659ADEE60EC";
        signByDefault = true;
      };
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      defaultCacheTtl = 1800;
    };

    programs.neovim = nvim-cfg;

    programs.zsh = {
      enable = true;
      shellAliases = {
        ls = "ls -al --color -F";
        cp = "cp -i";
        update = "sudo nixos-rebuild switch";
      };
      history = {
        size = 50000;
        path = "/home/natty/zsh/history";
      };
      enableCompletion = true;
      enableSyntaxHighlighting = true;
      enableAutosuggestions = true;
      autocd = true;
      historySubstringSearch = {
        enable = true;
      };
      initExtraBeforeCompInit = ''
        P10K_INSTANT_PROMPT="$XDG_CACHE_HOME/p10k-instant-prompt-''${(%):-%n}.zsh"
        [[ ! -r "$P10K_INSTANT_PROMPT" ]] || source "$P10K_INSTANT_PROMPT"
      '';
      plugins = with pkgs; [
        {
          file = "powerlevel10k.zsh-theme";
          name = "powerlevel10k";
          src = "${zsh-powerlevel10k}/share/zsh-powerlevel10k";
        }
        {
          file = "p10k.zsh";
          name = "powerlevel10k-config";
          src = "/etc/nixos/p10k/";
        }
      ];
      envExtra = ''
        LESS_TERMCAP_mb=''$'\E[01;32m'
        LESS_TERMCAP_md=''$'\E[01;32m'
        LESS_TERMCAP_me=''$'\E[0m'
        LESS_TERMCAP_se=''$'\E[0m'
        LESS_TERMCAP_so=''$'\E[01;47;34m'
        LESS_TERMCAP_ue=''$'\E[0m'
        LESS_TERMCAP_us=''$'\E[01;36m'
        LESS=-r
        WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
        '';
      initExtra = ''
        bindkey -e
        bindkey '^[[7~' beginning-of-line
        bindkey '^[[H' beginning-of-line
        if [[ "''${terminfo[khome]}" != "" ]]; then
          bindkey "''${terminfo[khome]}" beginning-of-line
        fi
        bindkey '^[[8~' end-of-line
        bindkey '^[[F' end-of-line
        if [[ "''${terminfo[kend]}" != "" ]]; then
          bindkey "''${terminfo[kend]}" end-of-line
        fi
        bindkey '^[[2~' overwrite-mode
        bindkey '^[[3~' delete-char
        bindkey '^[[C'  forward-char
        bindkey '^[[D'  backward-char
        bindkey '^[[5~' history-beginning-search-backward
        bindkey '^[[6~' history-beginning-search-forward

        bindkey '^[Oc' forward-word
        bindkey '^[Od' backward-word
        bindkey '^[[1;5D' backward-word
        bindkey '^[[1;5C' forward-word
        bindkey '^H' backward-kill-word

        bindkey '\e[3;5~' kill-word
        bindkey '^[[Z' undo
      '';
    };

    gtk.enable = true;
    gtk.font.name = "Roboto Regular";
    gtk.theme.name = "adw-gtk3-dark";
    gtk.iconTheme.name = "Papirus-Dark";
  };
}
