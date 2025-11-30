{ config, pkgs, ... }:

{
  # 启用 fastfetch
  programs.fastfetch = {
    enable = true;

    # 设置自定义配置（可选）
    settings = {
      # 显示配置
      display = {
        # 自定义 logo 和颜色
        logo = {
          source = "nixos";  # 使用 nixos logo
          color = "blue";    # logo 颜色
          width = 25;        # logo 宽度
        };

        # 信息项配置
        items = [
          "title"
          "separator"
          "os"
          "host"
          "kernel"
          "uptime"
          "packages"
          "shell"
          "resolution"
          "de"
          "wm"
          "terminal"
          "cpu"
          "gpu"
          "memory"
          "disk"
          "break"
          "colors"
        ];
      };

      # 通用配置
      general = {
        # 隐藏标题
        hideTitle = false;
        # 退出时打印换行
        printNewLine = true;
      };
    };
  };

  # 安装 fastfetch 包
  environment.systemPackages = with pkgs; [
    fastfetch
  ];
}
