{ firrtl }:
with import <nixpkgs> {};
with import ./util.nix;

let
  src = fetchFromGitHub {
    owner = "freechipsproject";
    repo = "chisel3";
    rev = "e1aa5f3f5c0cdeb204047c3ca50801d9f7ea25f1";
    sha256 = "1349q70hcy14cqpl8ff9v052na3qsyzaaf7180vh771jzd057gq4";
  };

coreMacros = scalaProject {
  name = "coreMacros";
  src = "${src}/coreMacros";
  deps = [];
};

chiselFrontend = scalaProject {
  name = "chiselFrontend";
  src = "${src}/chiselFrontend";
  deps = [
    firrtl
    coreMacros
    "scala-logging_2.12"
  ];
};

in
scalaProject {
  name = "chisel3";
  src = "${src}/src/main";

  deps = [
    firrtl
    coreMacros
    chiselFrontend
    "scala-logging_2.12"
    "scopt_2.12"
    "scalacheck_2.12"
    "scalatest_2.12"
    "scalactic_2.12"
    "scala-reflect"
    "moultingyaml_2.12"
  ];
}
