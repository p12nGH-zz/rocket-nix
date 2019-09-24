with import <nixpkgs> {};
with import ./util.nix;

let

  src = fetchFromGitHub {
    owner = "freechipsproject";
    repo = "firrtl";
    rev = "5e9b286185e98c58e5fde1987c48d085ebdb1e25";
    sha256 = "0y0lqa4r7401zkzymigcw2g8adyvkr02nxsgc8pbnz6r2z8kx0q3";
  };

  deps = [
    "scala-reflect"
    "scala-logging_2.12"
    "scalatest_2.12"
    "scalacheck_2.12"
    "scopt_2.12"
    "moultingyaml_2.12"
    "json4s-native_2.12"
    "json4s-jackson_2.12"
    "json4s-ext_2.12"
    "json4s-core_2.12"
    "json4s-ast_2.12"
    "nscala-time_2.12"
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
  inherit src;
  name = "firrtl";
  env = buildEnv {
    name = name;
    paths = buildInputs;
  };
  inherit bash scala_2_12;
  CLASSPATH = mkCP deps;

  jre = jre8_headless;
  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup
    set +x
    : Classpath: $CLASSPATH

    java org.antlr.v4.Tool \
      -package firrtl.antlr -visitor -no-listener -o firrtl/antlr $(find $src -name \*g4)

    cp $(find $src -name \*.proto) .
    protoc *.proto --java_out=.

    mkdir compiled
    scalac \
      -deprecation -Yrangepos -unchecked -language:implicitConversions -Xsource:2.11 \
      $(find $src/src/main/scala/ -name '*.scala') $(find . -name \*.java) \
      -d compiled

    javac -classpath $CLASSPATH:compiled $(find . -name \*.java) -d compiled

    mkdir -p $out/share/java
    cd compiled
    jar cf $out/share/java/firrtl.jar .
    cd ..

    mkdir -p $out/bin
    echo "#!$bash/bin/bash" > $out/bin/firrtl
    echo "exec $jre/bin/java -cp $CLASSPATH:$scala_2_12/lib/scala-library.jar:$out/share/java/firrtl.jar firrtl.stage.FirrtlMain \$@" >> $out/bin/firrtl
    chmod +x $out/bin/firrtl
  '';

  buildInputs = [
    scala_2_12
    openjdk
    protobuf
  ];
  passthru.jars
    = [ "${this}/share/java/firrtl.jar" ]
    ++ (jarLookupDeps deps);
})
