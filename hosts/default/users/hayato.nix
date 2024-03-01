{ config, pkgs, ... }:

{
  users.users = {
    hayato = {
      isNormalUser = true;
      extraGroups = ["wheel"];
      shell = pkgs.zsh;
    };
  };
}