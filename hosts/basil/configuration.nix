{ config, pkgs, ... }:

{
  networking.hostName = "basil";

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  time.timeZone = "Europe/London";

  users.users.jagd = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  environment.systemPackages = with pkgs; [
    git
    vim
  ];

  services.openssh.enable = true;

  system.stateVersion = "22.05";
}
