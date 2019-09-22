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

  cp = mkCP [
    "scala-reflect"
    "scala-logging_2.11"
  ];

in
stdenv.mkDerivation rec {
  name = "chisel3";
  env = buildEnv {
    name = name;
    paths = buildInputs;
  };
  inherit  cp src;
  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup

    set -xe

    echo $src
    mkdir -p $out/share/java
    scalac \
      -classpath $cp: \
      -deprecation -Yrangepos -unchecked -language:implicitConversions -Xsource:2.11 \
      $(find $src/coreMacros -name '*.scala') \
      -d $out/share/java/chisel3.jar
  '';

  buildInputs = [
    scala_2_11
    openjdk
    protobuf
  ];
  passthru.jar = (placeholder "out") + "/share/java/chisel3.jar";
}
