# ra-engine.nix
# module for building OpenRA from source.
# does not enable the use of mods
{pkgs, mods ? [] , pname ? "OpenRA", version ? "23.08",  src, ...} :
with builtins;
let 
lua51 = pkgs.lua51Packages.lua;

dotnet = with pkgs; [dotnet-sdk dotnet-runtime];

# platform segregation
isLinux  = elem pkgs.system ["x86_64-linux"   "aarch64-linux"]; 
isDarwin = elem pkgs.system [ "x86_64-darwin" "aarch64-darwin"];

baseNativeBuildInputs = with pkgs; [ toybox rsync ];
linuxNativeBuildInputs = with pkgs; [mono gnumake openal SDL2 openal libGL freetype lua51];
darwinNativeBuildInputs = with pkgs; [] ++ dotnet;

condList = c : l : if c then l else [];

baseMakeFlags = [ "TARGETPLATFORM=unix-generic" ];
linuxMakeFlags = ["RUNTIME=mono"];
darwinMakeFlags = [];


in
pkgs.buildDotnetModule {
  inherit pname version src;

  # build inputs
  nativeBuildInputs = baseNativeBuildInputs 
  ++ (condList isLinux linuxNativeBuildInputs) 
  ++ (condList isDarwin darwinNativeBuildInputs);

  # try to make use of mono instead of dotnet.
  makeFlags = baseMakeFlags ++ (condList isLinux linuxMakeFlags) ++ (condList isDarwin darwinMakeFlags);

  # quite unecessary : we should try to avoid copying useless files
  unpackPhase = '' ${pkgs.rsync}/bin/rsync -a $src/* ./'';

  installPhase = ''
    ls -la
  '';
}
