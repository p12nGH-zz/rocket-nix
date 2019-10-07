{ chisel3, hardfloat }:
with import <nixpkgs> {};
with import ./util.nix;

let
  api-config-chipsalliance = let
    src = fetchFromGitHub {
      owner = "chipsalliance";
      repo = "api-config-chipsalliance";
      rev = "d619ca850846d2ec36da64bf8a28e7d9a3d9ed1b";
      sha256 = "0cr0v2i8619c1mzq27yf7bg19dzkb50h1x2c0crr04m83wjapny5";
    };
  in
    scalaProject {
      name = "api-config-chipsalliance";
      src = "${src}/design";
      deps = [];
    };

  src = fetchFromGitHub {
    owner = "chipsalliance";
    repo = "rocket-chip";
    rev = "d42b521df4596bd6425b675794a06da08991eea0";
    sha256 = "0yaq76zw07pjxsrf4pjy98jlixy8zdjw2k69jn4sk9y0lca0rv2s";
  };

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
    deps = [
      rocketchip-macros
      chisel3
      hardfloat
      api-config-chipsalliance
      "jackson-databind"
      "jackson-core"
      "jackson-annotations"
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
{
  rocketchip = mkExe {
    jar = rocketchip;
    class =  "freechips.rocketchip.system.Generator";
  };
  rocketchip-src = src;
}
