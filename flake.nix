# flake.nix
# the flake responsible for all my systems and apps
{
  description = "Kanix, the nix flake for OpenRA";

  # flake inputs :
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    #Open-RA
    openRA = {
      url = "github:OpenRA/OpenRA";
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
  let 

      # we try to support every system
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];

      forAllSystems = function:
        nixpkgs.lib.genAttrs systems
        (system: function nixpkgs.legacyPackages.${system});

      ra-engine = pkgs : import ./ra-engine {inherit pkgs; src = inputs.openRA;};
  in
  {
       # pre-defined godot engine 
      packages = forAllSystems (pkgs: rec {
        openRA = ra-engine pkgs;
        default = openRA;
      });
  };
}