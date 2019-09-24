{ chisel3 }:
with import <nixpkgs> {};
with import ./util.nix;

let
  src = fetchFromGitHub {
    owner = "ucb-bar";
    repo = "berkeley-hardfloat";
    rev = "3ca9cc7901b91ddccf3fcfd686aa7a93ed48d84f";
    sha256 = "0ybyxcqiyrcg2jhacjq83zpmghxsn3x9rpb0wdigcz9xk1mvpisg";
  };

in
  scalaProject {
    name = "hardfloat";
    src = "${src}/src/main/scala";
    deps = [
      chisel3
    ];
    scalac_options = "-Xsource:2.11";
  }

