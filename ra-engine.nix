# ra-engine.nix
# module for building OpenRA from source.
# does not enable the use of mods
{pkgs, mods ? [] , pname ? "OpenRA", version ? "release-20230225",  src, ...} :
with builtins;
let 

lua51 = pkgs.lua51Packages.lua;

# cannot run without those
runtimeDependancies = with pkgs; [ toybox mono dotnet-sdk_7 openal SDL2 freetype lua51];
buildDependancies = with pkgs; [ msbuild rsync gnumake ];

libPaths = concatStringsSep " " (map (x : "${x}/lib") runtimeDependancies);

make = "${pkgs.gnumake}/bin/make";
rs ="${pkgs.rsync}/bin/rsync";
#launchGame = pkgs.stdenv.writeShellScriptBin "launchGame" 


in
pkgs.stdenv.mkDerivation rec {
  inherit pname version src;

  # native build inputs (used for compile time)
  nativeBuildInputs = runtimeDependancies ++ buildDependancies;
  buildInputs = runtimeDependancies;

  # try to make use of mono instead of dotnet.
  makeFlags = ["TARGETPLATFORM=unix-generic" "RUNTIME=mono" ];

  # quite unecessary : we should try to avoid copying useless files
  unpackPhase = ''
    ${rs}  -a $src/* ./
  '';


  # in order :
  # fix for read only
  # fix for version
  # fix for finding system libraries (Linux and Darwin)
  # fix for finding system libraries (Darwin)
  # fix for wrong naming of lua lib (Darwin)
  # fix for  "error : 'release-20230225' is not a valid version string."
  patchPhase = ''
    chmod +w ./ -R
    echo "${version}" > ./VERSION
    substituteInPlace configure-system-libraries.sh --replace '/usr/local/lib' '/usr/local/lib ${libPaths}'
    substituteInPlace configure-system-libraries.sh --replace '/opt/homebrew/lib' '/opt/homebrew/lib ${libPaths}'
    substituteInPlace configure-system-libraries.sh --replace 'liblua5.1.dylib' 'liblua.5.1.dylib'
    substituteInPlace Makefile --replace '-p:TargetPlatform=$(TARGETPLATFORM)' '-p:TargetPlatform=$(TARGETPLATFORM) -p:Version=0.0.0.0'
  '';

  installPhase = ''
    mkdir -p $out/bin
    ls -la > files.txt
    ${rs} -a bin $out/bin
    ${rs} -a *.sh $out
  '';
}
