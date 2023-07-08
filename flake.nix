{
  description = "zig-example-webserver nix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
 
  outputs = {
    self,
    flake-utils,
    zig-overlay,
    nixpkgs,
    devshell,
    ...
  }: 
  (flake-utils.lib.eachDefaultSystem
    (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [zig-overlay.overlays.default devshell.overlays.default];
        };
    in 
    {
      defaultPackage = pkgs.stdenv.mkDerivation {
        pname = "example-zig-webserver";
        version = "master";
        src = ./.;

        buildInputs = [ pkgs.zigpkgs.master ];
        preBuild = ''
          export HOME=$TMPDIR;
        '';

        buildPhase = ''
          mkdir -p $out
          ${pkgs.zigpkgs.master}/bin/zig build run --prefix $out
        '';

        # required for compilation
        XDG_CACHE_HOME = ".cache";
      };

      defaultApp = flake-utils.lib.mkApp {
        drv = self.defaultPackage."${system}";
      };

      devShells.default = import ./shell.nix { inherit pkgs; };
    })
  );
}
