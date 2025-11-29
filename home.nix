{ config, pkgs, inputs, ... }:

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
  programs.kitty = {
    enable = true;
  };

  # ============ 方法1：直接克隆 Fish 配置仓库 ============
  programs.fish.enable = true;

  # 使用你的 Fish 配置仓库
  home.file.".config/fish".source = myFishConfig;

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
  };

  # 确保必要的目录存在
  home.activation.createConfigDir = config.lib.dag.entryAfter ["writeBoundary"] ''
    mkdir -p ${config.home.homeDirectory}/.config
  '';

  home.stateVersion = "25.11";
}
