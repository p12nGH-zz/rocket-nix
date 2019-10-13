{ dependencies, util, nixpkgs }:

with nixpkgs;
with util;

let
  deps = with dependencies.java; with dependencies.scala; [
    scala-reflect
    scala-logging
    scalatest
    scalacheck
    scopt
    moultingyaml
    json4s-native
    json4s-jackson
    json4s-ext
    json4s-core
    json4s-ast
    json4s-scalap
    nscala-time
    logback-classic
    junit
    commons-text
    antlr4
    antlr4-runtime
    antlr-complete
    protobuf-java
    joda-time
    paranamer
    commons-lang3
  ];
in
fix (this: stdenv.mkDerivation rec {
  src = dependencies.fromGitHub.freechipsproject.firrtl;
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
