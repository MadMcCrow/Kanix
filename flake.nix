# flake.nix
# the flake responsible for all my systems and apps
{
  description = "Kanix, the nix flake for OpenRA";

  # flake inputs :
  inputs = {
    # Nixpkgs flake input
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    #Open-RA
    openRA = {
      url = "github:OpenRA/OpenRA/bleed";
      flake = false;
    };

    # the sdk to build OpenRA mods
    OpenRAModSDK = {
      url = "github:OpenRA/OpenRAModSDK";
      flake = false;
    };

    # RA2 : a mod to get RA2 data to run on the OpenRA engine
    openRA2 = {
      url = "github:OpenRA/ra2";
      flake = false;
    };

    # Dune 2 : a mod to get Dune 2 Data to run on the OpenRA engine
    Dune2 = {
      url = "github:OpenRA/d2";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, ... } @inputs :
  with builtins;
  with (nixpkgs) lib;
  let 

  systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
  forAllSystems = f : nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

  fetchGitHubRelease = { owner, repo, version, file, sha256 } : fetchurl {
    url = "https://github.com/${owner}/${repo}/releases/download/${version}/${file}";
    inherit sha256;
   };

  # TODO : allow other flakes to build the version they want
  openRA-Sources = fetchGitHubRelease rec {
      owner = "openRA";
      repo = "OpenRA";
      version = "release-20230225";
      file = "${version}-source.tar.gz";
      sha = "";
    };

    ra-engine = pkgs : import ./ra-engine.nix {inherit pkgs; src = inputs.openRA;};

  in
  {
       # pre-defined godot engine 
      packages = forAllSystems (pkgs: rec {
        openRA = ra-engine pkgs;
        default = openRA;
      });
  };
}