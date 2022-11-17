[root@nixos:/mnt/persist/etc/nixos]# cat configuration.nix.original
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (let commit = "02a45d9965133434c7b816cab2f47c8a7505e764"; in builtins.fetchTarball {
        # Pick a commit from the branch you are interested in
        url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${commit}/nixos-mailserver-${commit}.tar.gz";
        # And set its hash
        sha256 = "04v66z0ijjm8bqpiqmq1aqrqj6r6jjz591lgijmk4frz7lksnz8k";
      })
    ];

  nix.nixPath =
    [
      "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
      "nixos-config=/persist/etc/nixos/configuration.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r ${ZFS_BLANK_SNAPSHOT}
  '';

  boot.kernelParams = [ "elevator=none" ];
  networking.hostName = mail;
  networking.hostId = "$(head -c 8 /etc/machine-id)";
  time.timeZone = "Asia/Kolkata";
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  environment.gnome.excludePackages = [
    pkgs.gnome.cheese pkgs.gnome-photos pkgs.gnome.gnome-music pkgs.gnome.gedit
    pkgs.epiphany pkgs.gnome.gnome-characters pkgs.gnome.totem pkgs.gnome.tali
    pkgs.gnome.iagno pkgs.gnome.hitori pkgs.gnome.atomix pkgs.gnome-tour
    pkgs.gnome.geary
  ];

  environment.systemPackages = with pkgs;
    [
      nixops nixFlakes screen gnupg gnumake zip unzip bind dnsutils jitsi-meet opendkim zfstools gitea wireguard-tools wirelesstools wpa_supplicant mailutils nixopsUnstable openssl cacert openssh openldap tpm2-pkcs11 tpm2-tools tpm2-tss age sops mysql ntfsprogs btrfs-progs efivar efitools terraform acme iptables ripgrep cloudflared nvidia-vaapi-driver fail2ban opentabletdriver docker clamav vim chromium pciutils usbutils imagemagick sshfs gnome3.gnome-tweaks qemu_kvm firefox wget libvirt git jq tree
    ];
  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;
  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = false;
    hostKeys =
      [
        {
          path = "/persist/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/persist/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
          bits = 4096;
        }
      ];
  };

  users = {
    mutableUsers = false;
    users = {
      root = {
        initialHashedPassword = "${ROOT_PASSWORD_HASH}";
      };

      alpha = {
        createHome = true;
        isNormalUser = true;
        initialHashedPassword = "$6$vSxOJL1W76MXsQcM$uzmwDqdhgec.kx7e2Yc6qGPNw0uN09uWul18JVabS8qVM1U5314NUkuoyvSHQoZUL.K9e2ULjCWKLavqYx8Hr0";
        extraGroups = [ "wheel" "plugdev" "dialout" "audio" "video" "bluetooth" "networkmanager" "docker" "libvirtd" ];
        group = "users";
        uid = 1000;
        home = "/home/alpha";
        useDefaultShell = true;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMLl2D6DW05109/Ahzif5c3hs7yOvYEd+CEfigySHHgy root@gh-dr"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDm30g4383TSVHmwz2zgWPqQ893jqgTtPs6JYCMbZh+s root@dns"
        ];
      };
    };
  };

  # boot.loader.grub.enable = true;
  # boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  # boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;




  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     firefox
  #     thunderbird
  #   ];
  # };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

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

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
