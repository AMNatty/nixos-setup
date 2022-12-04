{ config, pkgs, ... }:

{
  boot.supportedFilesystems = [ "ntfs" ];

  fileSystems."/drives/code" = {
    device = "/dev/disk/by-uuid/57ad52d0-641d-45af-8dea-75cbed3d068a";
    fsType = "btrfs";
  };

  fileSystems."/drives/config" = {
    device = "/dev/disk/by-uuid/33391f6e-cbfd-481a-91c9-10fb5f4a2f7d";
    fsType = "btrfs";
  };

  fileSystems."/drives/personal" = {
    device = "/dev/disk/by-uuid/6004246404243F80";
    fsType = "ntfs3";
    options = [ "rw" "nodev" "uid=1000"];
  };

  fileSystems."/drives/storage" = {
    device = "/dev/disk/by-uuid/14FE3603FE35DDA4";
    fsType = "ntfs3";
    options = [ "rw" "nodev" "uid=1000"];
  };

  fileSystems."/drives/windows" = {
    device = "/dev/disk/by-uuid/72549A1E5499E4DF";
    fsType = "ntfs3";
    options = [ "rw" "nodev" "uid=1000"];
  };
}
