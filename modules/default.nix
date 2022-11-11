
{ config, pkgs, ... }:

{
  # Install fonts
  fonts.fonts = with pkgs; [
    hack-font
    font-awesome
  ];

  # Font and keymap
  console = {
    font = "Hack";
    keyMap = "en";
  };

  # Locale and timezone
  i18n.defaultLocale = "en_GB.UTF-8";
  time.timeZone = "Asia/Kolkata";

  # User account
  users.users.alpha = {
    isNormalUser = true;
    extraGroups = [ "wheel" "adb-users" "audio" "libvirtd" "docker" ];
  };

  # Auto upgrades
  system.autoUpgrade.enable = true;

  # Remove old generations
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 8d";

  imports = [
    ./includes/cli.nix
  ];
}
