{
  description = "egui/eframe development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
    # Runtime libs winit/wgpu need; missing these causes
    # WaylandError(Connection(NoWaylandLib)) and Wgpu(CreateSurfaceError).
    runtimeLibs = with pkgs; [
      wayland
      libxkbcommon
      vulkan-loader
      mesa
      libGL
      libX11
      libXcursor
      libXi
      libXrandr
      xkeyboard-config
    ];
  in {
    devShells.${system}.default = pkgs.mkShell {
      name = "egui";

      packages = with pkgs; [
        rustc
        cargo
        rustfmt
        clippy
        rust-analyzer
      ];

      buildInputs = runtimeLibs;

      RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";

      shellHook = ''
        export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath runtimeLibs}:''${LD_LIBRARY_PATH:-}"
        export XKB_CONFIG_ROOT="${pkgs.xkeyboard-config}/share/X11/xkb"
        export WINIT_UNIX_BACKEND="''${WINIT_UNIX_BACKEND:-wayland,x11}"
      '';
    };
  };
}
