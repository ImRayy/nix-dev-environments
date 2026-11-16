{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    devShells.${system}.default = pkgs.mkShell {
      nativeBuildInputs = with pkgs; [
        pkg-config
        wrapGAppsHook3
        cargo
        rustc
        rustup
        bun
        # tools linuxdeploy and its plugins shell out to
        file
        patchelf
        binutils
        squashfsTools
      ];

      buildInputs = with pkgs; [
        gtk3
        webkitgtk_4_1
        libsoup_3
        glib
        glib-networking
        gdk-pixbuf
        cairo
        pango
        harfbuzz
        atk
        librsvg
        openssl
        libayatana-appindicator
        xdotool

        gsettings-desktop-schemas

        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-ugly
        gst_all_1.gst-libav
      ];

      # tauri's downloaded linuxdeploy is an AppImage; run it without FUSE
      APPIMAGE_EXTRACT_AND_RUN = "1";
      # nix's strip and the bundled one disagree on some libs
      NO_STRIP = "1";

      shellHook = ''
        export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:''${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
        export RUST_SRC_PATH="${pkgs.rustPlatform.rustLibSrc}"
      '';
    };
  };
}
