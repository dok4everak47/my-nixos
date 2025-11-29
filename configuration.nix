# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib,  ... }:

{

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  # boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;

  # Grub
  boot.loader.grub = {
    enable = true;
    efiSupport = true; # Set to true for UEFI systems
    # useOSProber = true; # Set to true if you need to boot other OSes
    device = "nodev"; # Set to your boot drive (e.g., /dev/sda)
  };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # 启用输入法支持
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      fcitx5-table-extra
      fcitx5-gtk # GTK 程序支持
      rime-data
      kdePackages.fcitx5-qt
      qt6Packages.fcitx5-configtool
    ];
  };

  # 环境变量设置
  environment.variables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };

  # 启用 fish shell
  programs.fish.enable = true;

  # 设置 fish 为默认 shell
  users.users.dok4ever.shell = pkgs.fish;

  # 配置蓝牙
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  
  # 或者对所有用户设置（可选）
  # users.defaultUserShell = pkgs.fish;

  services.xserver.videoDrivers = [ "modesetting" ];

   hardware.graphics = {
     enable = true;
     extraPackages = with pkgs; [
       intel-media-driver
       vpl-gpu-rt          # for newer GPUs on NixOS >24.05 or unstable
       # onevpl-intel-gpu  # for newer GPUs on NixOS <= 24.05
       # intel-media-sdk   # for older GPUs
     ];
   };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";     # Prefer the modern iHD backend
    # VDPAU_DRIVER = "va_gl";      # Only if using libvdpau-va-gl
  };

  # May help if FFmpeg/VAAPI/QSV init fails (esp. on Arc with i915):
  hardware.enableRedistributableFirmware = true;
  boot.kernelParams = [ "i915.enable_guc=3" ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dok4ever = {
    isNormalUser = true;
    description = "dok4ever";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable flatpak
  services.flatpak.enable = true;

  # 启用 Flakes 特性以及配套的船新 nix 命令行工具
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     wget
     git
     neovim
     fastfetch
     yazi
     kdePackages.filelight
     yt-dlp
     wpsoffice-cn
     fish

     v2rayn

     vscode

     # alacritty
     kitty

     steam

     haruna

     vdhcoapp

     yutto

     telegram-desktop

  ];

  # 将默认编辑器设置为 nvim
  environment.variables.EDITOR = "nvim";

  fonts = {
    fonts = with pkgs; [
      dejavu_fonts
      # 中文字体包
      wqy_microhei
      wqy_zenhei
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      
      # 可选：其他中文字体
      source-han-sans
      source-han-serif
      sarasa-gothic
    ];
    
    # 启用字体缓存
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "Sarasa Mono SC" "DejaVu Sans Mono" ];
        sansSerif = [ "Source Han Sans SC" "Noto Sans CJK SC" ];
        serif = [ "Source Han Serif SC" "Noto Serif CJK SC" ];
      };
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  
  nix.settings.substituters = [ "https://mirrors.ustc.edu.cn/nix-channels/store" ];
  system.stateVersion = "25.11"; # Did you read the comment?

}
