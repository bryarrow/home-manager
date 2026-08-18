{ writeShellApplication
, nix
, perl
}:

writeShellApplication {
  name = "hm-apps";

  runtimeInputs = [
    nix
    perl
  ];

  text = builtins.readFile ./hm-apps.sh;
}
