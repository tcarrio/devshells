{
  description = "Development shell environments";

  # Flake inputs
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    nixphps.url = "github:fossar/nix-phps";
    nixpkgs2205.url = "github:NixOS/nixpkgs/22.05";
  };

  # Flake outputs
  outputs = { self, nixpkgs, nixphps, nixpkgs2205 }:
    let
      # Systems supported
      allSystems = [
        "x86_64-linux" # 64-bit Intel/ARM Linux
        "aarch64-linux" # 64-bit AMD Linux
        "x86_64-darwin" # 64-bit Intel/ARM macOS
        "aarch64-darwin" # 64-bit Apple Silicon
      ];

      node16Overlay = final: pre: {
        nodejs = self.nodejs-16_x;
      };
      yarn16Overlay = final: pre: {
        yarn = super.yarn.override {
          nodejs = self.nodejs-16_x;
        };
      };

      node18Overlay = final: pre: {
        nodejs = self.nodejs-18_x;
      };
      yarn18Overlay = final: pre: {
        yarn = super.yarn.override {
          nodejs = self.nodejs-18_x;
        };
      };

      # Helper to provide system-specific attributes
      nameValuePair = name: value: { inherit name value; };
      genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);
      forAllSystems = f: genAttrs allSystems (system: f {
        pkgs = import nixpkgs {
          inherit system;
        };
        pkgsNode16 = import nixpkgs {
          inherit system;
          overlays = [node16Overlay yarn16Overlay];
        };
        pkgsNode18 = import nixpkgs {
          inherit system;
          overlays = [node18Overlay yarn18Overlay];
        };
        pkgs2205 = import nixpkgs2205 { inherit system; };
      });
    in
    {
      # Development environment output
      devShells = forAllSystems ({ pkgs, pkgsNode16, pkgsNode18, pkgs2205 }:
        let
          coreShellPackages = [
            pkgs.zsh
          ];
          coreDevPackages = [
            pkgs.git
            pkgs.jq
            pkgs.sops
          ];
          coreNode16Packages = [
            pkgsNode16.nodejs-16_x
            pkgsNode16.yarn
            pkgs.python3 # required for native compilation of common libraries such as node-sass
          ];
          coreNode18Packages = [
            pkgsNode18.nodejs-18_x
            pkgsNode18.yarn
            pkgs.python3 # required for native compilation of common libraries such as node-sass
          ];
          corePhpPackages = [
            pkgs.libpng
          ];
          php74Packages = [
            nixphps.packages.${pkgs.system}.php74
            nixphps.packages.${pkgs.system}.php74.packages.composer
          ];
          php80Packages = [
            pkgs.php80
            pkgs.php80.packages.composer
          ];
          php81Packages = [
            pkgs.php81
            pkgs.php81.packages.composer
          ];
          php82Packages = [
            pkgs.php82
            pkgs.php82.packages.composer
          ];
          emptyStr = "";
          shellHookCommandFactory = { git ? true, php ? false, node ? false, yarn ? false, pnpm ? false, python ? false, bun ? false }: ''
            echo $ Started devenv shell for $PROJECT_NAME
            echo
            ${if git    then ''git --version''                             else emptyStr}
            ${if node   then ''echo "node version $(node --version)"''     else emptyStr}
            ${if yarn   then ''echo "yarn version $(yarn --version)"''     else emptyStr}
            ${if pnpm   then ''echo "pnpm version $(pnpm --version)"''     else emptyStr}
            ${if python then ''echo "python version $(python --version)"'' else emptyStr}
            ${if php    then ''php --version''                             else emptyStr}
            ${if bun    then ''echo "bun version $(bun --version)"''       else emptyStr}
            echo
          '';
          phpShellHookCommand = shellHookCommandFactory { php = true; };
          nodeShellHookCommand = shellHookCommandFactory { node = true; yarn = true; };
        in 
        {
          ### Generic language shells (NodeJS, PHP, etc.)

          node16 = pkgs.mkShell {
            packages = with pkgsNode16; [
              nodePackages.pnpm
            ] ++ coreShellPackages ++ coreDevPackages ++ coreNode16Packages;

            PROJECT_NAME = "NodeJS LTS v16";

            shellHook = nodeShellHookCommand;
          };

          node18 = pkgs.mkShell {
            packages = with pkgsNode18; [
              nodePackages.pnpm
            ] ++ coreShellPackages ++ coreDevPackages ++ coreNode18Packages;

            PROJECT_NAME = "NodeJS LTS v18";

            shellHook = nodeShellHookCommand;
          };

          php74 = pkgs.mkShell {
            packages = coreShellPackages ++ coreDevPackages ++ corePhpPackages ++ php74Packages;

            PROJECT_NAME = "PHP74";

            shellHook = phpShellHookCommand;
          };

          php80 = pkgs.mkShell {
            packages = coreShellPackages ++ coreDevPackages ++ corePhpPackages ++ php80Packages;

            PROJECT_NAME = "PHP80";

            shellHook = phpShellHookCommand;
          };

          php81 = pkgs.mkShell {
            packages = coreShellPackages ++ coreDevPackages ++ corePhpPackages ++ php81Packages;

            PROJECT_NAME = "PHP81";

            shellHook = phpShellHookCommand;
          };

          php82 = pkgs.mkShell {
            packages = coreShellPackages ++ coreDevPackages ++ corePhpPackages ++ php82Packages;

            PROJECT_NAME = "PHP82";

            shellHook = phpShellHookCommand;
          };

          python = pkgs.mkShell {
            packages = [
              pkgs.python3
            ] ++ coreShellPackages ++ coreDevPackages;

            PROJECT_NAME = "Python";

            shellHook = shellHookCommandFactory { python = true; };
          };

          bun = pkgs.mkShell {
            packages = [
              pkgs.bun
            ] ++ coreShellPackages ++ coreDevPackages;

            PROJECT_NAME = "Bun";

            shellHook = shellHookCommandFactory { bun = true; };
          };
        }
      );
    };
}
