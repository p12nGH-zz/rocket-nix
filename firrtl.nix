with import <nixpkgs> {};
with import ./util.nix;

let

  src = fetchFromGitHub {
    owner = "freechipsproject";
    repo = "firrtl";
    rev = "5e9b286185e98c58e5fde1987c48d085ebdb1e25";
    sha256 = "0y0lqa4r7401zkzymigcw2g8adyvkr02nxsgc8pbnz6r2z8kx0q3";
  };

  cp = mkCP [
    "scala-reflect"
    "scala-logging_2.11"
    "scalatest_2.11"
    "scalacheck_2.11"
    "scopt_2.11"
    "moultingyaml_2.11"
    "json4s-native_2.11"
    "json4s-jackson_2.11"
    "json4s-ext_2.11"
    "json4s-core_2.11"
    "json4s-ast_2.11"
    "nscala-time_2.11"
    "logback-classic"
    "junit"
    "commons-text"
    "antlr4"
    "antlr4-runtime"
    "antlr-complete"
    "protobuf-java"
    "joda-time"
  ];

in
fix (this: stdenv.mkDerivation rec {
  name = "firrtl";
  env = buildEnv {
    name = name;
    paths = buildInputs;
  };
  inherit bash scala_2_11 cp;
  jre = jre8_headless;
  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup

    set -xe

    echo $src
    java -classpath $cp org.antlr.v4.Tool \
      -package firrtl.antlr -visitor -no-listener -o firrtl/antlr $(find $src -name \*g4)

    cp $(find $src -name \*.proto) .
    protoc *.proto --java_out=.
    javaFiles=$(find $PWD/firrtl -name \*java)

    mkdir -p $out/share/java
    scalac \
      -classpath $cp: \
      -deprecation -Yrangepos -unchecked -language:implicitConversions -Xsource:2.11 \
      $(find $src/src/main/scala/ -name '*.scala') $javaFiles -d $out/share/java/firrtl.jar
    mkdir -p $out/bin
    echo "#!$bash/bin/bash" > $out/bin/firrtl
    echo "exec $jre/bin/java -cp $cp:$scala_2_11/lib/scala-library.jar:$out/share/java/firrtl.jar firrtl.stage.FirrtlMain \$@" >> $out/bin/firrtl
    chmod +x $out/bin/firrtl
  '';
  inherit src;

  buildInputs = [
    scala_2_11
    openjdk
    protobuf
  ];
  passthru.jar = "${this}/share/java/firrtl.jar";
})
