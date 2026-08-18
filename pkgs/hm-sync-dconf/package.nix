{ writeShellApplication
, dconf
, gnome-shell
, nix
, perl
}:

writeShellApplication {
  name = "hm-sync-dconf";

  runtimeInputs = [
    dconf
    gnome-shell
    nix
    perl
  ];

  text = builtins.readFile ./sync-dconf-to-home-manager.sh;
}
