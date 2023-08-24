# ra-engine.nix
# module for building OpenRA from source.
# does not enable the use of mods
{pkgs, mods ? [] , pname ? "OpenRA", version ? "23.08",  src, ...} :
with builtins;
let 
lua51 = pkgs.lua51Packages.lua;

dotnet = with pkgs; [dotnet-sdk dotnet-runtime];
monoBuild = with pkgs; [mono msbuild];

# platform segregation
isLinux  = elem pkgs.system ["x86_64-linux"   "aarch64-linux"]; 
isDarwin = elem pkgs.system [ "x86_64-darwin" "aarch64-darwin"];

baseNativeBuildInputs = with pkgs; [ toybox rsync  gnumake ]; # openal SDL2 freetype lua51];
linuxNativeBuildInputs =[];
darwinNativeBuildInputs = monoBuild;

condList = c : l : if c then l else [];

baseMakeFlags = ["TARGETPLATFORM=unix-generic"];
linuxMakeFlags = ["RUNTIME=mono"];
darwinMakeFlags = ["RUNTIME=mono"];


in
pkgs.stdenv.mkDerivation {
  inherit pname version src;

  # native build inputs (used for compile time)
  nativeBuildInputs = baseNativeBuildInputs ++
  condList isLinux linuxNativeBuildInputs ++ 
  condList isDarwin darwinNativeBuildInputs;

  # try to make use of mono instead of dotnet.
  makeFlags = baseMakeFlags ++ (condList isLinux linuxMakeFlags) ++ (condList isDarwin darwinMakeFlags);

  # quite unecessary : we should try to avoid copying useless files
  #unpackPhase = ''
  #fsefsrgrs
  #${pkgs.rsync}/bin/rsync -a $src/* ./
  #kfjesf;sj
  #'';

  installPhase = ''
    ls -la
  '';
}
