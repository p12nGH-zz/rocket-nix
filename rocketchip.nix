{ chisel3, hardfloat, dependencies, util, nixpkgs }:

with util;
with nixpkgs;

let
  api-config-chipsalliance = scalaProject {
      name = "api-config-chipsalliance";
      src = "${dependencies.fromGitHub.chipsalliance.api-config-chipsalliance}/design";
      deps = [];
    };

  src = dependencies.fromGitHub.chipsalliance.rocket-chip;

  rocketchip-macros = scalaProject {
    name = "rocketchip-macros";
    src = "${src}/macros/src/main/scala";
    deps = [
      chisel3
    ];
  };

  rocketchip = scalaProject {
    name = "rocketchip";
    src = "${src}/src/main/scala";
    deps = with dependencies.scala; with dependencies.java; [
      rocketchip-macros
      chisel3
      hardfloat
      api-config-chipsalliance
      jackson-databind
      jackson-core
      jackson-annotations
    ];
    scalac_options = "-Xsource:2.11";
  };

  mkExe = { jar, class }:
    let
      jre = jre8_headless;
      cp = mkCP [ jar ];
    in
      writeShellScriptBin jar.name ''
        exec ${jre}/bin/java -cp ${cp} ${class} $@
      '';

in
  mkExe {
    jar = rocketchip;
    class =  "freechips.rocketchip.system.Generator";
  }
