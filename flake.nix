{
  description = "Development shell environments";

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
    extra-trusted-substituters = [
      "https://cache.nixos.org"
    ];
  };

  # Flake inputs
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixphps.url = "github:fossar/nix-phps";
  };

  # Flake outputs
  outputs = { self, nixpkgs, nixphps }:
    let
      # Systems supported
      allSystems = [
        "x86_64-linux" # 64-bit Intel/ARM Linux
        "aarch64-linux" # 64-bit AMD Linux
        "x86_64-darwin" # 64-bit Intel/ARM macOS
        "aarch64-darwin" # 64-bit Apple Silicon
      ];

      yarn14Overlay = final: pre: {
        yarn = pre.yarn.override {
          nodejs = final.nodejs_14;
        };
      };

      yarn16Overlay = final: pre: {
        yarn = pre.yarn.override {
          nodejs = final.nodejs_16;
        };
      };

      yarn18Overlay = final: pre: {
        yarn = pre.yarn.override {
          nodejs = final.nodejs_18;
        };
      };

      yarn20Overlay = final: pre: {
        yarn = pre.yarn.override {
          nodejs = final.nodejs_20;
        };
      };

      yarn22Overlay = final: pre: {
        yarn = pre.yarn.override {
          nodejs = final.nodejs_22;
        };
      };

      yarn24Overlay = final: pre: {
        yarn = pre.yarn.override {
          nodejs = final.nodejs_24;
        };
      };

      # Helper to provide system-specific attributes

      importWithOverlays = system: overlays: import nixpkgs {
        inherit system;
        overlays = overlays;
      };
      nameValuePair = name: value: { inherit name value; };
      genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);
      forAllSystems = f: genAttrs allSystems (system: f {
        pkgs = importWithOverlays system [];
        pkgsNode14 = importWithOverlays system [yarn14Overlay];
        pkgsNode16 = importWithOverlays system [yarn16Overlay];
        pkgsNode18 = importWithOverlays system [yarn18Overlay];
        pkgsNode20 = importWithOverlays system [yarn20Overlay];
        pkgsNode22 = importWithOverlays system [yarn22Overlay];
        pkgsNode24 = importWithOverlays system [yarn24Overlay];
      });
    in
    {
      # Development environment output
      devShells = forAllSystems ({ pkgs, pkgsNode14, pkgsNode16, pkgsNode18, pkgsNode20, pkgsNode22, pkgsNode24 }:
        let
          coreShellPackages = [
            pkgs.zsh
          ];
          coreDevPackages = [
            pkgs.git
            pkgs.jq
            pkgs.sops
          ];
          coreNode14Packages = [
            pkgsNode14.nodejs_14
            pkgsNode14.yarn
            pkgs.python3 # required for native compilation of common libraries such as node-sass
          ];
          coreNode16Packages = [
            pkgsNode16.nodejs_16
            pkgsNode16.yarn
            pkgs.python3 # required for native compilation of common libraries such as node-sass
          ];
          coreNode18Packages = [
            pkgsNode18.nodejs_18
            pkgsNode18.yarn
            pkgs.python3 # required for native compilation of common libraries such as node-sass
          ];
          coreNode20Packages = [
            pkgsNode20.nodejs_20
            pkgsNode20.yarn
            pkgs.python3 # required for native compilation of common libraries such as node-sass
          ];
          coreNode22Packages = [
            pkgsNode22.nodejs_22
            pkgsNode24.yarn
            pkgs.python3 # required for native compilation of common libraries such as node-sass
          ];
          coreNode24Packages = [
            pkgsNode24.nodejs_24
            pkgsNode24.yarn
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
          php81Packages = with pkgs; [
            php81
            php81.packages.composer
          ];
          php82Packages = with pkgs; [
            php82
            php82.packages.composer
          ];
          php83Packages = with pkgs; [
            php83
            php83.packages.composer
          ];
          php84Packages = with pkgs; [
            php84
            php84.packages.composer
          ];
          emptyStr = "";
          shellHookCommandFactory = { git ? true, php ? false, node ? false, yarn ? false, pnpm ? false, python ? false, bun ? false, deno ? false }: ''
            echo $ Started devenv shell for $PROJECT_NAME
            echo
            ${if git    then ''git --version''                             else emptyStr}
            ${if node   then ''echo "node version $(node --version)"''     else emptyStr}
            ${if yarn   then ''echo "yarn version $(yarn --version)"''     else emptyStr}
            ${if pnpm   then ''echo "pnpm version $(pnpm --version)"''     else emptyStr}
            ${if python then ''echo "python version $(python --version)"'' else emptyStr}
            ${if php    then ''php --version''                             else emptyStr}
            ${if bun    then ''echo "bun version $(bun --version)"''       else emptyStr}
            ${if deno   then ''deno --version''                            else emptyStr}
            echo
          '';
          phpShellHookCommand = shellHookCommandFactory { php = true; };
          nodeShellHookCommand = shellHookCommandFactory { node = true; yarn = true; };
        in rec
        {
          ### Generic language shells (NodeJS, PHP, etc.)

          node14 = pkgs.mkShell {
            packages = with pkgsNode14;
              coreShellPackages ++ coreDevPackages ++ coreNode14Packages;

            PROJECT_NAME = "NodeJS LTS v14";

            shellHook = nodeShellHookCommand;
          };

          node16 = pkgs.mkShell {
            packages = with pkgsNode16;
              coreShellPackages ++ coreDevPackages ++ coreNode16Packages;

            PROJECT_NAME = "NodeJS LTS v16";

            shellHook = nodeShellHookCommand;
          };

          node18 = pkgs.mkShell {
            packages = with pkgsNode18;
              coreShellPackages ++ coreDevPackages ++ coreNode18Packages;

            PROJECT_NAME = "NodeJS LTS v18";

            shellHook = nodeShellHookCommand;
          };

          node20 = pkgs.mkShell {
            packages = with pkgsNode20;
              coreShellPackages ++ coreDevPackages ++ coreNode20Packages;

            PROJECT_NAME = "NodeJS LTS v20";

            shellHook = nodeShellHookCommand;
          };

          node22 = pkgs.mkShell {
            packages = with pkgsNode22;
              coreShellPackages ++ coreDevPackages ++ coreNode22Packages;

            PROJECT_NAME = "NodeJS LTS v22";

            shellHook = nodeShellHookCommand;
          };

          node24 = pkgs.mkShell {
            packages = with pkgsNode24;
              coreShellPackages ++ coreDevPackages ++ coreNode24Packages;

            PROJECT_NAME = "NodeJS LTS v24";

            shellHook = nodeShellHookCommand;
          };

          php74 = pkgs.mkShell {
            packages = coreShellPackages ++ coreDevPackages ++ corePhpPackages ++ php74Packages;

            PROJECT_NAME = "PHP 7.4";

            shellHook = phpShellHookCommand;
          };

          php80 = pkgs.mkShell {
            packages = coreShellPackages ++ coreDevPackages ++ corePhpPackages ++ php80Packages;

            PROJECT_NAME = "PHP 8.0";

            shellHook = phpShellHookCommand;
          };

          php81 = pkgs.mkShell {
            packages = coreShellPackages ++ coreDevPackages ++ corePhpPackages ++ php81Packages;

            PROJECT_NAME = "PHP 8.1";

            shellHook = phpShellHookCommand;
          };

          php82 = pkgs.mkShell {
            packages = coreShellPackages ++ coreDevPackages ++ corePhpPackages ++ php82Packages;

            PROJECT_NAME = "PHP 8.2";

            shellHook = phpShellHookCommand;
          };

          php83 = pkgs.mkShell {
            packages = coreShellPackages ++ coreDevPackages ++ corePhpPackages ++ php83Packages;

            PROJECT_NAME = "PHP 8.3";

            shellHook = phpShellHookCommand;
          };

          php84 = pkgs.mkShell {
            packages = coreShellPackages ++ coreDevPackages ++ corePhpPackages ++ php84Packages;

            PROJECT_NAME = "PHP 8.4";

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

          deno = pkgs.mkShell {
            packages = [
              pkgs.deno
            ] ++ coreShellPackages ++ coreDevPackages;

            PROJECT_NAME = "Deno";

            shellHook = shellHookCommandFactory { deno = true; };
          };

          # Project aliases
          "signalapp/Signal-Desktop" = pkgs.mkShell {
            packages = with pkgs; [
              python3
              gcc
              gnumake
              gnat
            ] ++ coreShellPackages ++ coreDevPackages ++ coreNode18Packages;
          };

          # Default aliases
          node = node24;
          php = php82;

          # Default shell for development in the project
          default = pkgs.mkShell {
            packages = [
              pkgs.nix
            ] ++ coreShellPackages ++ coreDevPackages;

            PROJECT_NAME = "Default";

            shellHook = shellHookCommandFactory {};
          };
        }
      );
    };
}
