{ firrtl }:
with import <nixpkgs> {};
with import ./util.nix;

let
  src = fetchFromGitHub {
    owner = "freechipsproject";
    repo = "chisel3";
    rev = "b03006e30904ed51fa94a47fbfd0f7b199498ca1";
    sha256 = "16rjcw9zqdwmd86jbnlw6144z42a4zpv5i0r37iiibrnjv1fqiar";
  };

  scalaProject = { name, src, deps }: fix (self: stdenv.mkDerivation {
    inherit name src;
    buildInputs = [ scala_2_11 ];
    CLASSPATH = mkCP deps;
    paradise = jarLookup "paradise_2.11.12";

    buildInfo = builtins.toFile "BuildInfo.scala" ''
      package ${name}

      case object BuildInfo {
        val version: String = "todo"
        override val toString: String = "BuildInfo toString not implemented"
      }

    '';

    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      set -xe

      mkdir -p $out/share/java
      : Classpath: $CLASSPATH
      scalac \
        -deprecation -Yrangepos -unchecked -language:implicitConversions -Xsource:2.11 \
        -Xplugin:$paradise \
        $buildInfo $(find $src -name '*.scala') \
        -d $out/share/java/$name.jar
      set +x 
    '';
    passthru.jars = [ "${self}/share/java/${name}.jar" ];
  });

in
rec {
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
      "scala-logging_2.11"
    ];
  };
  chisel3 = scalaProject {
    name = "chisel3";
    src = "${src}/src/main";

    deps = [
      firrtl
      coreMacros
      chiselFrontend
      "scala-logging_2.11"
      "scopt_2.11"
      "scalacheck_2.11"
      "scalatest_2.11"
      "scalactic_2.11"
      "scala-reflect"
    ];
  };
}
