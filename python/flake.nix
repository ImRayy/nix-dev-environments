{
  description = "Announcement Creator — Python + Jinja dev shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    devShells = forAllSystems (system: let
      pkgs = import nixpkgs {inherit system;};

      python = pkgs.python3.withPackages (ps:
        with ps; [
          jinja2
        ]);
    in {
      default = pkgs.mkShell {
        packages = [
          python
          pkgs.ruff
        ];

        shellHook = ''
          echo "announcement-creator dev shell"
          echo "python: $(python --version)"
          echo "jinja2: $(python -c 'import jinja2; print(jinja2.__version__)')"
        '';
      };
    });
  };
}
