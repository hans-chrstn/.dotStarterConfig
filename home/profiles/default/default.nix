{ config, pkgs, inputs, ... }:

{
  imports = [
    ./home.nix
    ./programs.nix
    ./programs
    ./fonts
    ./ui
  ];
}
