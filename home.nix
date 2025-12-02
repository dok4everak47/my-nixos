{ config, pkgs, inputs, lib, ... }:

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

  # 获取你的 Fish 配置
  myFishConfig = pkgs.fetchFromGitHub {
    owner = "dok4everak47";
    repo = "my_fish_config";
    rev = "My_PC_NixOS";
    sha256 = "sha256-EJSp4el45ls1B0eGyknDoMgQXT380WhD7rc7/bNhrR8=";
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
    ripgrep
    jq
    yq-go
    eza
    fzf
    bat
    curl

    # networking tools
    mtr
    iperf3
    dnsutils
    ldns
    aria2
    socat
    nmap
    ipcalc

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
    nix-output-monitor

    # productivity
    hugo
    glow

    btop
    iotop
    iftop

    # system call monitoring
    strace
    ltrace
    lsof

    # system tools
    sysstat
    lm_sensors
    ethtool
    pciutils
    usbutils

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

  # ============ 修正的 Kitty 配置 ============
  programs.kitty = {
    enable = true;

    # 字体配置（重要！添加这个）
    font = {
      name = "JetBrains Mono";
      size = 11;
    };

    # 其他设置
    settings = {
      confirm_os_window_close = 0;
      dynamic_background_opacity = true;
      enable_audio_bell = false;
      mouse_hide_wait = "-1.0";
      window_padding_width = 10;
      background_opacity = "0.5";
      background_blur = 5;

      # 保持你的符号映射
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

    # 额外的字体配置（可选）
    extraConfig = ''
      # 字体回退设置
      bold_font auto
      italic_font auto
      bold_italic_font auto

      # 如果需要中文字体支持
      # font_family JetBrains Mono
      # fallback_font Noto Sans CJK SC
    '';
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
  # （保持你的原配置不变）

  # 设置默认编辑器
  home.sessionVariables = {
    CLANGD_PATH = "/run/current-system/sw/bin/clangd";
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # 确保必要的目录存在
  home.activation.createConfigDir = config.lib.dag.entryAfter ["writeBoundary"] ''
    mkdir -p ${config.home.homeDirectory}/.config
  '';

  home.stateVersion = "25.11";
}
