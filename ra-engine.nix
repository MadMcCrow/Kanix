# ra-engine.nix
# module for building OpenRA from source.
# does not enable the use of mods
{pkgs, mods ? [] , pname ? "OpenRA", version ? "dev-23.08",  src, ...} : 
let 
lua51 = pkgs.lua51Packages.lua;
in
pkgs.stdenv.mkDerivation {
  inherit pname version;

  nativeBuildInputs = with pkgs; [mono gnumake openal SDL2 openal libGL freetype lua51];
  makeFlags = ["TARGETPLATFORM=unix-generic" "RUNTIME=mono"];
  #buildPhase = ''
  #  ${make} TARGETPLATFORM=unix-generic
  #  ''
  installPhase = ''
    ls -la
  '';
}
