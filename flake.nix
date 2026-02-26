{
  description = "routing-engine";

  inputs = {
    rust-template = {
      url = "git+https://gitlab.transics-cicd.aws.zf.com/transversal/routing/gitlab-cicd-templates.git?dir=nix-template/rust";
    };
    nixpkgs.follows = "rust-template/nixpkgs";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-template, nixos-generators, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-darwin" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };

        inherit (pkgs) lib;

        base = rust-template.templates.default {
          inherit system;
          config = {
            name = "routing-engine";
            src = ./.;
            filterExtraSuffixes = [
              # Keep proto files
              ".proto"
              # Keep GUI assets
              ".png"
              # Keep routing tests
              ".csv"
            ];
            filterExtraTestSuffixes = [
              # Keep proto files
              ".proto"
              # Keep pbf files
              ".pbf"
              # Keep geojson files
              ".geojson"
              # Keep json files
              ".json"
              # Keep GUI assets
              ".png"
              # Keep metis compressed files
              ".metis.gz"
              # Keep OpenLR files with encoded locations
              ".txt"
              # Keep routing tests
              ".csv"
            ];
            extraArgs = {
              nativeBuildInputs = [
                pkgs.protobuf
              ];
            };

            makeContainer = { pkgs, cargoPackage, name }: pkgs.dockerTools.buildImage {
              inherit name;
              tag = "latest";
              copyToRoot = pkgs.buildEnv {
                name = "image-root";
                paths = [ pkgs.cacert pkgs.busybox cargoPackage ];
                pathsToLink = [ "/bin" "/etc" ];
              };
            };
          };
        };
      in
      {
        packages = base.packages // {

          ec2 = nixos-generators.nixosGenerate {
            system = "x86_64-linux";
            specialArgs = {
              routing-engine = base.packages.default;
            };
            modules = [
              (nixpkgs.outPath + "/nixos/modules/profiles/headless.nix")
              (nixpkgs.outPath + "/nixos/modules/profiles/minimal.nix")
              {
                disabledModules = [
                  (nixpkgs.outPath + "/nixos/modules/virtualisation/ec2-data.nix")
                  (nixpkgs.outPath + "/nixos/modules/virtualisation/amazon-init.nix")
                ];
                ec2.zfs.enable = false;
                ec2.efi = true;

                virtualisation.diskSize = "auto";

                programs.nano.enable = false;

                services.openssh.enable = lib.mkForce false;
                services.amazon-ssm-agent.enable = lib.mkForce false;


                # perlless remove grub
                # for some reason, systemd-boot brings nix and its huge
                # didn't find a way to boot without grub or systemd-boot

                #(nixpkgs.outPath + "/nixos/modules/profiles/perlless.nix")
                #boot.loader.grub.enable = false;
                #boot.loader.systemd-boot.enable = true;

                nix.enable = false;


                services.lvm.enable = false;
                security.sudo.enable = false;

                # not sure udev is needed, to be checked
                #services.udev.enable = false;


              }
              ./configuration.nix
            ];
            format = "amazon";
          };
        };
        checks = base.checks;

        devShells = {
          default = base.devShells.default;
          gui = pkgs.mkShell rec {
            inputsFrom = [ base.devShells.default ];
            buildInputs = with pkgs; [
              # misc. libraries
              openssl
              pkg-config

              # GUI libs
              libxkbcommon
              libGL
              mesa
              fontconfig

              # wayland libraries
              wayland

              # x11 libraries
              xorg.libXcursor
              xorg.libXrandr
              xorg.libXi
              xorg.libX11
            ];

            LD_LIBRARY_PATH = "${lib.makeLibraryPath buildInputs}";
          };

        };
      }
    );
}
