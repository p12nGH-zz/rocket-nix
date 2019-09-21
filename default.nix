with import <nixpkgs> {};

let
  scalaVersion = "2.12";

  src = fetchFromGitHub {
    owner = "freechipsproject";
    repo = "firrtl";
    rev = "5e9b286185e98c58e5fde1987c48d085ebdb1e25";
    sha256 = "0y0lqa4r7401zkzymigcw2g8adyvkr02nxsgc8pbnz6r2z8kx0q3";
  };

  mavenDep = l: fetchMavenArtifact {
    artifactId = builtins.elemAt l 0;
    groupId = builtins.elemAt l 1;
    version = builtins.elemAt l 2;
    sha256 = builtins.elemAt l 3;
  };

  scala_2_12_deps = map mavenDep [
    [ "scala-reflect"        "org.scala-lang"              "2.12.8"       "0niiazlnflwz7j9f5ap9bl9l4gly6f1a12x0rq2cx6a5bhwhar2d" ]
    [ "scala-logging_2.12"   "com.typesafe.scala-logging"  "3.9.0"        "1g08fhvycn2vfqvxsgq27s8rfy24v1a1fl0v5jhrjsz2j6c3q1sq" ]
    [ "scalatest_2.12"       "org.scalatest"               "3.0.5"        "1r85w0m5m9rs52yf25nkslf2vz2pwhk5g2ldk93dl837xyyba5ml" ]
    [ "scalacheck_2.12"      "org.scalacheck"              "1.14.0"       "0bp6xkzbllrcblyw3yg781gdkdrjcs0lfl0rfjz06jxp5clmnvqy" ]
    [ "scopt_2.12"           "com.github.scopt"            "3.7.0"        "0micrr3iwq6bcxqxdra9gj0njypxm4qk5144k9my0rzj34lgy18i" ]
    [ "moultingyaml_2.12"    "net.jcazevedo"               "0.4.0"        "1zg9z799pd9hs32x3f2190h58ldpdy6mj9xyma02wia6vb38x4b9" ]
    [ "json4s-native_2.12"   "org.json4s"                  "3.6.1"        "0zkkg4b1n3bv8i7w5alv0h1dfarcmdk94lrvlw37sq90p3d6niva" ]
    [ "json4s-jackson_2.12"  "org.json4s"                  "3.6.1"        "0hw0r0ar3wq4fc8x2kpd4b42s9938rkdmlvx7nnj5w39ksim9f43" ]
    [ "json4s-ext_2.12"      "org.json4s"                  "3.6.1"        "0hz4igzissb1kspajjvrri1fswqa25gmlbn7zvsdfr2c11acqa84" ]
    [ "json4s-core_2.12"     "org.json4s"                  "3.6.1"        "1h6szj8v5np6fkn8424djy6mxndsczsn9fihbcllx8i9ji883x70" ]
    [ "json4s-ast_2.12"      "org.json4s"                  "3.6.1"        "0ikpdxwqss0jva60iil3mxcjxgsvqr76hgaf1kmk53pj3mhdxirr" ]
  ];

  scala_2_11_deps = map mavenDep [
    [ "scala-reflect"        "org.scala-lang"              "2.11.8"       "06a3idk3ywl7dy1fiy014j0aqqv8r1mnrq0ifj3dwd9ad9283q19" ]
    [ "scala-logging_2.11"   "com.typesafe.scala-logging"  "3.9.0"        "1r2jxmrvcw7nzzd7drs5lmryah68v8gy47gmjil0ccv8fcn24n3g" ]
    [ "scalatest_2.11"       "org.scalatest"               "3.0.5"        "0bxsv5zfpa62nha51lrry11zziydkvglgmzrjnxcn4kr4m0ypbra" ]
    [ "scalacheck_2.11"      "org.scalacheck"              "1.14.0"       "0xmjll5m3hz9y85ypvh690a9lsaakypwya60lirb2vrrlf2kmkww" ]
    [ "scopt_2.11"           "com.github.scopt"            "3.7.0"        "1dbh8krh9k9x1lcn52wjawyry0qjcdavxdrjv2v4b6wz6ynbc1fc" ]
    [ "moultingyaml_2.11"    "net.jcazevedo"               "0.4.0"        "1ck92hysgmimxj7gsjx31b1zhpc7v271xk0ksv9yw5bm09h1fvm7" ]
    [ "json4s-native_2.11"   "org.json4s"                  "3.6.1"        "15r971qzazq8iq1pqbkid8h8nb315drdgyqix5vifc1cw12yvyim" ]
    [ "json4s-jackson_2.11"  "org.json4s"                  "3.6.1"        "1p49v3kab6rx3sybsbv073ng3i8csw196aa3q3yn6dfky9wzmg4f" ]
    [ "json4s-ext_2.11"      "org.json4s"                  "3.6.1"        "1rwilkka7yyf1h2blayrgq7gg0cmzr72h66s976djzk63nfc4aij" ]
    [ "json4s-core_2.11"     "org.json4s"                  "3.6.1"        "0g7f24vijaj80k0apcgl1qb5cz9cwirri5gs9b896fiian2yw34z" ]
    [ "json4s-ast_2.11"      "org.json4s"                  "3.6.1"        "1bbcwiq0c8096skldriwngf0817mzfmxfc5z3p31dax05fyxlam6" ]
    [ "nscala-time_2.11"     "com.github.nscala-time"      "2.16.0"       "1gh6n6q2ni79rff3pc6yipks0635yf901lzcazx9sbyxfm9q436c" ]
  ];

  misc_deps = map mavenDep [
    [ "logback-classic"      "ch.qos.logback"              "1.2.3"        "1q1pmkmsadlaknsj1c7b1741vv2n408kiqan784qzjvzkr9zhlzv" ]
    [ "junit"                "junit"                       "4.12"         "0shibkq1faqc7j8cl0n5swscazanzzcqfy37j15xh8z20l41ywjr" ]
    [ "commons-text"         "org.apache.commons"          "1.6"          "02x702m3yzy1wyc09xms13q8p3qmri1rsg4m2vkhygmn95jyaifz" ]
    [ "antlr4"               "org.antlr"                   "4.7.1"        "11qd1ak24wdra5pbdczdjla5msw0s1adqs15hcl3g2gbz3rc5kd2" ]
    [ "antlr4-runtime"       "org.antlr"                   "4.7.1"        "07f91mjclacrvkl8a307w2abq5wcqp0gcsnh0jg90ddfpqcnsla3" ]
    [ "antlr-complete"       "org.antlr"                   "3.5.2"        "0srjwxipwsfzmpi0v32d1l5lzk9gi5in8ayg33sq8wyp8ygnbji6" ]
    [ "protobuf-java"        "com.google.protobuf"         "3.8.0"        "03z6kgkmg0hqw7cplh8wbd5mbhknwqwqzamg97mhgbfxd6l91fll" ]
    [ "joda-time"            "joda-time"                   "2.10.3"       "12cfaw67vsg57d8wc7nvb5phzwh4k7zrharzmbjs5yrnvsmaddpb" ]
  ];

  mkCP = deps:
    builtins.concatStringsSep ":" (map (d: d.jar) deps);

in
stdenv.mkDerivation rec {
  name = "firrtl";
  env = buildEnv {
    name = name;
    paths = buildInputs;
  };
  cp = mkCP (scala_2_11_deps ++ misc_deps);
  inherit  bash scala_2_11;
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
      $(find $src/src/main/scala/ -name '*.scala') $javaFiles
    jar cf $out/share/java/firrtl.jar $(find . -name \*.class)
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
  passthru.jar = (placeholder "out") + "/share/java/firrtl.jar";
}
