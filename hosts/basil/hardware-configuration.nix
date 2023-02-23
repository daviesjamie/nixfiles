{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "local/volatile/root";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/34EB-E578";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "local/persistent/home";
    fsType = "zfs";
  };

  fileSystems."/nix" = {
    device = "local/persistent/nix";
    fsType = "zfs";
  };

  fileSystems."/persist" = {
    device = "local/persistent/persist";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/var/log" = {
    device = "local/persistent/var-log";
    fsType = "zfs";
  };

  swapDevices = [];

  nixpkgs.hostPlatform.system = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
