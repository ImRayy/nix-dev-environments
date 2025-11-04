{
  description = "NixOS electron dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        fhs = pkgs.buildFHSEnv {
          name = "electron-fhs-shell";
          targetPkgs = pkgs:
            (with pkgs; [
              alsa-lib
              atkmm
              at-spi2-atk
              cairo
              cups
              dbus
              expat
              glib
              glibc
              gtk2
              gtk3
              gtk4
              libdrm
              libxkbcommon
              libgbm
              mesa
              nspr
              nss
              nodePackages.pnpm
              nodejs_20
              pango
              udev
              libxcrypt-legacy
              libGL
              zlib
            ])
            ++ (with pkgs.xorg; [
              libXcomposite
              libXdamage
              libXext
              libXfixes
              libXrandr
              libX11
              xcbutil
              libxcb
            ]);
        };
      in {
        devShells.default = fhs.env;
      }
    );
}
