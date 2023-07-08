{ pkgs ? (
    let
      inherit (builtins) fetchTree fromJSON readFile;
      inherit ((fromJSON (readFile ./flake.lock)).nodes) nixpkgs devshell;
    in
    import (fetchTree nixpkgs.locked) {
      overlays = [];
    }
  )
}: let
in
pkgs.devshell.mkShell {
  packages = [
    pkgs.zigpkgs.master
  ];
  imports = [ (pkgs.devshell.importTOML ./devshell.toml) ];
}
