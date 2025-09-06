{ config, pkgs, lib, ... }:

{
  # Enable ZRAM swap
  zramSwap.enable = true;

  # Optional: set ZRAM size (default is half your RAM)
  # zramSwap.swapSize = 8 * 1024 * 1024 * 1024; # 8 GB
}
