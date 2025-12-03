{ config, pkgs, inputs, lib,  ... }:

let
  # 创建包含所有必要 Python 工具的 Python 环境
  myPython = pkgs.python3.withPackages (ps: with ps; [
    pip
    setuptools
    isort
    black
    flake8
    pylint
    virtualenv
    pipx
  ]);

  # 获取你的 AstroVim 配置
  astronvimConfig = pkgs.fetchFromGitHub {
    owner = "dok4everak47";
    repo = "My-AstroVim-Config";
    rev = "main";
    sha256 = "sha256-3exKmvxFYzpoFAQ0bkHAuTFupEvpB7cmSnpMVSW1JrY=";
  };

  # 获取你的 Fish 配置
  myFishConfig = pkgs.fetchFromGitHub {
    owner = "dok4everak47";
    repo = "my_fish_config";
    rev = "My_PC_NixOS";
    sha256 = "sha256-EJSp4el45ls1B0eGyknDoMgQXT380WhD7rc7/bNhrR8=";
    # sha256 = "sha256-tchS1AQH7UXK9EN2WKUj3pGuB29t4jrTb0mLsjQKbXA="; # main
  };

in
{
  home.username = "dok4ever";
  home.homeDirectory = "/home/dok4ever";

  # 设置鼠标指针大小以及字体 DPI（适用于 4K 显示器）
  xresources.properties = {
    "Xcursor.size" = 32;
  };

  # 通过 home.packages 安装一些常用的软件
  home.packages = with pkgs;[
    # ... 你原有的包列表保持不变

    # archives
    zip
    xz
    unzip
    p7zip
    kdePackages.ark
    unrar

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processor https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls'
    fzf # A command-line fuzzy finder
    bat
    curl

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils  # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc  # it is a calculator for the IPv4/v6 addresses

    # misc
    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    # productivity
    hugo # static site generator
    glow # markdown previewer in terminal

    btop  # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb

    # ============ 修正的 AstroVim 相关依赖 ============
    myPython
    neovim
    git
    lua
    nodejs
    tree-sitter
    lazygit
    gdu
    bottom
    gcc
    rustc
    cargo
    fd
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted
    pyright
    rust-analyzer
    lua-language-server
    nil
    nodePackages.prettier
    shellcheck
    shfmt
    gopls
    haskell-language-server

    # ============ Fish 相关依赖 ============
    fish
    fzf
    bat
    eza
    git
  ];

  # git 相关配置
  programs.git = {
    enable = true;
    userName = "dok4ever";
    userEmail = "dok4ever@qq.com";
  };

  # 启用kitty

  programs.kitty = lib.mkForce {
  enable = true;
  settings = {
    confirm_os_window_close = 0;
    dynamic_background_opacity = true;
    enable_audio_bell = false;
    mouse_hide_wait = "-1.0";
    window_padding_width = 10;
    background_opacity = "0.5";
    background_blur = 5;
    symbol_map = let
      mappings = [
        "U+23FB-U+23FE"
        "U+2B58"
        "U+E200-U+E2A9"
        "U+E0A0-U+E0A3"
        "U+E0B0-U+E0BF"
        "U+E0C0-U+E0C8"
        "U+E0CC-U+E0CF"
        "U+E0D0-U+E0D2"
        "U+E0D4"
        "U+E700-U+E7C5"
        "U+F000-U+F2E0"
        "U+2665"
        "U+26A1"
        "U+F400-U+F4A8"
        "U+F67C"
        "U+E000-U+E00A"
        "U+F300-U+F313"
        "U+E5FA-U+E62B"
      ];
    in
      (builtins.concatStringsSep "," mappings) + " Symbols Nerd Font";
  };
};

  # ============ 方法1：直接克隆 Fish 配置仓库 ============
  programs.fish.enable = true;

  # 使用你的 Fish 配置仓库
  home.file.".config/fish".source = myFishConfig;

  home.file.".config/ripgreprc".text = ''
    # ripgrep 配置文件
    --color=always
    --smart-case
    --hidden
    --follow
    --max-columns=150

    # 忽略的目录/文件
    --glob=!node_modules/
    --glob=!.git/
    --glob=!*.min.js
    --glob=!*.bundle.js
    --glob=!dist/
    --glob=!build/
    --glob=!target/

  '';


  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
      # 添加 Python 包路径
      export PATH="$PATH:${myPython}/bin"
      export PYTHONPATH="${myPython}/${myPython.sitePackages}"
    '';

    shellAliases = {
      k = "kubectl";
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
      vim = "nvim";
      vi = "nvim";
    };
  };

  # ============ 修正的 AstroVim 配置 ============

  # 使用 activation script 在每次切换时设置可写的配置
  home.activation.setupNeovim = config.lib.dag.entryAfter ["writeBoundary"] ''
    NVIM_CONFIG="$HOME/.config/nvim"
    CONFIG_SRC="${astronvimConfig}"

    # 如果配置目录不存在，或者源配置有更新，则重新复制
    if [ ! -d "$NVIM_CONFIG" ] || [ ! -f "$NVIM_CONFIG/init.lua" ]; then
      echo "Setting up Neovim configuration..."
      rm -rf "$NVIM_CONFIG"
      cp -r "$CONFIG_SRC" "$NVIM_CONFIG"
      chmod -R u+w "$NVIM_CONFIG"
      echo "Neovim configuration copied and made writable"
    elif [ "$CONFIG_SRC/init.lua" -nt "$NVIM_CONFIG/init.lua" ]; then
      echo "Updating Neovim configuration..."
      rm -rf "$NVIM_CONFIG"
      cp -r "$CONFIG_SRC" "$NVIM_CONFIG"
      chmod -R u+w "$NVIM_CONFIG"
      echo "Neovim configuration updated"
    fi
  '';

  # 设置默认编辑器
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";

    RIPGREP_CONFIG_PATH = "${config.home.homeDirectory}/.config/ripgreprc";

    # Haruna 相关环境变量
  DEFAULT_VIDEO_PLAYER = "haruna";
  VIDEO_PLAYER = "haruna";
  AUDIO_PLAYER = "haruna";
  MEDIA_PLAYER = "haruna";

  # 特定应用程序的变量
  MPLAYER = "haruna";
  SMPLAYER = "haruna";

  # XDG 相关
  XDG_VIDEO_PLAYER = "haruna";
  XDG_AUDIO_PLAYER = "haruna";
  };

  xdg.configFile."mimeapps.list".force = true;
  xdg.configFile."mimeapps.list".text = ''
    [Default Applications]
    video/mp4=haruna.desktop
    video/x-matroska=haruna.desktop
    video/avi=haruna.desktop
    video/x-msvideo=haruna.desktop
    video/quicktime=haruna.desktop
    video/x-flv=haruna.desktop
    video/webm=haruna.desktop
    video/mpeg=haruna.desktop
    video/3gpp=haruna.desktop
    video/x-ms-wmv=haruna.desktop

    audio/mpeg=haruna.desktop
    audio/x-wav=haruna.desktop
    audio/flac=haruna.desktop
    audio/ogg=haruna.desktop
    audio/x-m4a=haruna.desktop
    audio/x-ms-wma=haruna.desktop
    audio/aac=haruna.desktop

    application/x-matroska=haruna.desktop
    application/ogg=haruna.desktop

    # 保持其他应用程序的默认设置
    [Added Associations]
    video/mp4=haruna.desktop;
    video/x-matroska=haruna.desktop;
    video/avi=haruna.desktop;
    video/x-msvideo=haruna.desktop;
    video/quicktime=haruna.desktop;
    video/x-flv=haruna.desktop;
    video/webm=haruna.desktop;
    video/mpeg=haruna.desktop;
    video/3gpp=haruna.desktop;
    video/x-ms-wmv=haruna.desktop;
    audio/mpeg=haruna.desktop;
    audio/x-wav=haruna.desktop;
    audio/flac=haruna.desktop;
    audio/ogg=haruna.desktop;
    audio/x-m4a=haruna.desktop;
    audio/x-ms-wma=haruna.desktop;
    audio/aac=haruna.desktop;
    application/x-matroska=haruna.desktop;
    application/ogg=haruna.desktop;
  '';

  home.activation.setupHarunaMime = config.lib.dag.entryAfter ["writeBoundary"] ''
  # 确保 mimeapps.list 文件存在
  MIMEAPPS_FILE="$HOME/.config/mimeapps.list"

  if [ ! -f "$MIMEAPPS_FILE" ]; then
    echo "Creating mimeapps.list..."
    mkdir -p "$HOME/.config"
    touch "$MIMEAPPS_FILE"
  fi

  # 更新 mimeapps.list 中的 Haruna 配置
  echo "Updating MIME associations for Haruna..."

  # 使用 xdg-mime 命令行工具设置
  if command -v xdg-mime >/dev/null 2>&1; then
    # 视频类型
    for mime in video/mp4 video/x-matroska video/avi video/x-msvideo \
                video/quicktime video/x-flv video/webm video/mpeg \
                video/3gpp video/x-ms-wmv; do
      xdg-mime default haruna.desktop "$mime" 2>/dev/null || true
    done

    # 音频类型
    for mime in audio/mpeg audio/x-wav audio/flac audio/ogg \
                audio/x-m4a audio/x-ms-wma audio/aac; do
      xdg-mime default haruna.desktop "$mime" 2>/dev/null || true
    done

    # 容器格式
    xdg-mime default haruna.desktop application/x-matroska 2>/dev/null || true
    xdg-mime default haruna.desktop application/ogg 2>/dev/null || true
  fi
'';

  xdg.configFile."yazi/init.lua".text = ''
    -- yazi 初始化配置
    ya = ya or {}

    -- 设置打开规则：所有文件都使用 xdg-open
    ya.open = {
      rules = {
        {
          matcher = function(file)
            return true  -- 匹配所有文件
          end,
          use = function(files)
            -- 对每个文件使用 xdg-open
            for _, file in ipairs(files) do
              os.execute("xdg-open " .. vim.fn.shellescape(file))
            end
          end
        }
      }
    }
  '';

  # 确保必要的目录存在
  home.activation.createConfigDir = config.lib.dag.entryAfter ["writeBoundary"] ''
    mkdir -p ${config.home.homeDirectory}/.config
  '';

  home.stateVersion = "25.11";
}
