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

  # 启用 Fish shell
  programs.fish.enable = true;

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

  # 删除之前的符号链接配置
  # home.file.".config/nvim" = { ... };

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
