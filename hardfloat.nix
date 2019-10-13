{ chisel3, dependencies, scalaProject }:

scalaProject {
  name = "hardfloat";
  src = "${dependencies.fromGitHub.ucb-bar.berkeley-hardfloat}/src/main/scala";
  deps = [ chisel3 ];
  scalac_options = "-Xsource:2.11";
}

