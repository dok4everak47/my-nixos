{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS 官方软件源，这里使用 nixos-25.11 分支
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux"; # 添加系统架构
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.dok4ever = import ./home.nix;
        }

        # 添加 fastfetch 配置模块
        ({ config, pkgs, lib, ... }:
        {
          environment.systemPackages = with pkgs; [ fastfetch ];

          # 下载并使用 fastfetch 配置文件
          environment.etc."fastfetch/config.jsonc".source =
            builtins.fetchurl {
              url = "https://raw.githubusercontent.com/dok4everak47/fastfetch-presets/main/24.jsonc";
              # 第一次构建时会报错，使用报错中提示的正确 hash 替换下面的值
              sha256 = "1mr39b0xfpg48nrrdwnjzhvcmn0qfi702l14s1ylxb842szlsaap";
            };
        })
      ];
    };
  };
}
