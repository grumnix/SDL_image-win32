{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";

    tinycmmc.url = "github:grumbel/tinycmmc";
    tinycmmc.inputs.nixpkgs.follows = "nixpkgs";

    SDL-win32.url = "github:grumnix/SDL-win32";
    SDL-win32.inputs.nixpkgs.follows = "nixpkgs";
    SDL-win32.inputs.tinycmmc.follows = "tinycmmc";

    SDL_image_src.url = "https://github.com/libsdl-org/SDL_image/archive/refs/tags/release-1.2.12.tar.gz";
    SDL_image_src.flake = false;
  };

  outputs = { self, nixpkgs, tinycmmc, SDL-win32, SDL_image_src }:
    tinycmmc.lib.eachWin32SystemWithPkgs (pkgs:
      {
        packages = rec {
          default = SDL_image;

          SDL_image = pkgs.stdenv.mkDerivation {
            pname = "SDL_image";
            version = "1.2.12";

            src = SDL_image_src;

            nativeBuildInputs = [
              pkgs.buildPackages.pkgconfig
            ];

            buildInputs = [
              SDL-win32.packages.${pkgs.system}.default

              pkgs.libpng
              (pkgs.libjpeg_original.overrideAttrs (oldAttrs: { meta = {}; }))
            ];
          };
        };
      }
    );
}
