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
        bun
      ];

      buildInputs = with pkgs; [
        # gtk / webkit / soup stack required by tauri v2 on linux
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

        # gsettings schemas so gtk/webkit can resolve display scale etc.
        gsettings-desktop-schemas

        # webkit gstreamer backend
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-ugly
        gst_all_1.gst-libav
      ];

      shellHook = ''
        # let gtk/webkit find gsettings schemas (needed on wayland for correct scale)
        export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:''${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"

        # runtime libs for the cargo-built binary launched outside of a wrapper
        export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [
          pkgs.gtk3
          pkgs.webkitgtk_4_1
          pkgs.libsoup_3
          pkgs.gdk-pixbuf
          pkgs.cairo
          pkgs.pango
          pkgs.harfbuzz
          pkgs.atk
          pkgs.librsvg
          pkgs.libayatana-appindicator
          pkgs.xdotool
        ]}:''${LD_LIBRARY_PATH:-}"

        export RUST_SRC_PATH="${pkgs.rustPlatform.rustLibSrc}";
      '';
    };
  };
}
