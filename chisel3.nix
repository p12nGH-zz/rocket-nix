{ firrtl, dependencies, scalaProject }:

with dependencies.scala;
with dependencies.java;

let
  src = dependencies.fromGitHub.freechipsproject.chisel3;

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
      scala-logging
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
      scala-logging
      scopt
      scalacheck
      scalatest
      scalactic
      scala-reflect
      moultingyaml
    ];
  }
