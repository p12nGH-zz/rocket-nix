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
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      set -xe

      mkdir -p $out/share/java
      : Classpath: $CLASSPATH
      scalac \
        -deprecation -Yrangepos -unchecked -language:implicitConversions -Xsource:2.11 \
        -Xplugin:$paradise \
        $(find $src -name '*.scala') \
        -d $out/share/java/$name.jar
      set +x 
    '';
    passthru.jar = self + "/share/java/${name}.jar";
  });

in
rec {
  chisel3-coreMacros = scalaProject {
    name = "chisel3-coreMacros";
    src = "${src}/coreMacros";
    deps = [];
  };

  chisel3-chiselFrontend = scalaProject {
    name = "chisel3-chiselFrontend";
    src = "${src}/chiselFrontend";
    deps = [
      firrtl
      chisel3-coreMacros
      "scala-logging_2.11"
    ];
  };
}
