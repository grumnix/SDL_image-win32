{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-24.05";

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
      let
        libpng = pkgs.libpng;
        libjpeg = (pkgs.libjpeg_original.overrideAttrs (oldAttrs: { meta = {}; }));
      in
      {
        packages = rec {
          default = SDL_image;

          SDL_image = pkgs.stdenv.mkDerivation {
            pname = "SDL_image";
            version = "1.2.12";

            src = SDL_image_src;

            postFixup = ''
              ln -sfv ${libpng}/bin/*.dll $out/bin/
              ln -sfv ${libjpeg}/bin/*.dll $out/bin/

              # Required by libpng, but not provided by it
              ln -sfv ${pkgs.zlib}/bin/*.dll $out/bin/
            '';

            nativeBuildInputs = [
              pkgs.buildPackages.pkg-config
            ];

            buildInputs = [
              SDL-win32.packages.${pkgs.system}.default

              libpng
              libjpeg
            ];
          };
        };
      }
    );
}
